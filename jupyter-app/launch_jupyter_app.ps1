param([int]$Port = 8890)

# --- Ensure we are running in an STA host so WPF can render reliably ---
try {
  if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    $psExe = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"
    Start-Process -FilePath $psExe -ArgumentList @(
      "-NoProfile",
      "-ExecutionPolicy","Bypass",
      "-STA",
      "-File", $PSCommandPath,
      "-Port", $Port
    ) | Out-Null
    exit 0
  }
} catch { }

$ErrorActionPreference = "Stop"
$StartDir = $env:USERPROFILE
$LogFile  = Join-Path $env:TEMP "jupyter_app_launcher.log"

function Log($m) {
  Add-Content -Path $LogFile -Value ("[{0}] {1}" -f (Get-Date).ToString("yyyy-MM-dd HH:mm:ss"), $m)
}

function Fail($m) {
  Log "ERROR: $m"
  try {
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show("$m`n`nLog: $LogFile","Jupyter App")
  } catch {
    Write-Host $m -ForegroundColor Red
    Write-Host "Log: $LogFile"
  }
  exit 1
}

function Show-LoadingWindow {
  Add-Type -AssemblyName PresentationFramework

  # PNG must be in the same folder as this .ps1
  $imgPath = Join-Path (Split-Path $PSCommandPath) "jupyter_loading_screen.png"
  if (-not (Test-Path $imgPath)) {
    Fail "Missing image: $imgPath"
  }

  $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStyle="None" ResizeMode="NoResize"
        Width="520" Height="360"
        Background="#222" AllowsTransparency="True"
        Topmost="True" WindowStartupLocation="CenterScreen"
        ShowInTaskbar="False">
  <Grid Margin="18">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <TextBlock Text="Launching JupyterLab..."
               Foreground="#EEE"
               FontSize="20"
               HorizontalAlignment="Center"
               Margin="0,8,0,14"/>

    <!-- Image source is bound to Window.DataContext -->
    <Image Grid.Row="1"
           Source="{Binding}"
           Height="120"
           Stretch="Uniform"
           HorizontalAlignment="Center"
           Margin="0,0,0,18"/>

    <TextBlock Grid.Row="2"
               Text="by Arnav Kalekar"
               Foreground="#CCC"
               FontSize="14"
               HorizontalAlignment="Center"
               Margin="0,6"/>

    <TextBlock Grid.Row="3"
               Text="v1.0.0   &#x2022;   Feb 2026"
               Foreground="#AAA"
               FontSize="12"
               HorizontalAlignment="Center"
               Margin="0,2"/>

    <TextBlock Grid.Row="4"
               Text="Not affiliated with Project Jupyter."
               Foreground="#666"
               FontSize="11"
               HorizontalAlignment="Center"
               Margin="0,12,0,0"/>
  </Grid>
</Window>
"@

  $reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
  $win = [Windows.Markup.XamlReader]::Load($reader)

  # Bind image path to the <Image Source="{Binding}">
  $win.DataContext = $imgPath

  $null = $win.Show()
  return $win
}

function Pump-UI {
  try {
    $disp = [System.Windows.Threading.Dispatcher]::CurrentDispatcher
    $disp.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
  } catch { }
}

function Find-Python {
  $py = Get-Command "py.exe" -ErrorAction SilentlyContinue
  if ($py) { return @{File="py.exe";Prefix="-3"} }
  $py2 = Get-Command "python.exe" -ErrorAction SilentlyContinue
  if ($py2) { return @{File="python.exe";Prefix=""} }
  return $null
}

function KillOnPort([int]$p) {
  $g = Get-Command "Get-NetTCPConnection" -ErrorAction SilentlyContinue
  if ($g) {
    $conns = Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue
    foreach ($c in $conns) {
      $procId = $c.OwningProcess
      if ($procId) { Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue }
    }
    return
  }
  $lines = & cmd.exe /c "netstat -ano | findstr :$p | findstr LISTENING"
  foreach ($l in $lines) {
    $parts = ($l -split "\s+") | Where-Object {$_ -ne ""}
    $procId = $parts[-1]
    if ($procId -match "^\d+$") { & cmd.exe /c "taskkill /PID $procId /F" | Out-Null }
  }
}

function WaitUp([int]$p,[int]$ms) {
  $t = [Math]::Ceiling($ms/200)
  for ($i=0;$i -lt $t;$i++) {
    Start-Sleep -Milliseconds 200
    Pump-UI
    $c = Test-NetConnection 127.0.0.1 -Port $p -WarningAction SilentlyContinue
    if ($c.TcpTestSucceeded) { return $true }
  }
  return $false
}

$win = $null

try {
  Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
  Log "START"

  if (-not (Test-Path $StartDir)) { Fail "HOME not found: $StartDir" }

  # Show loading window
  $win = Show-LoadingWindow
  Pump-UI

  KillOnPort $Port
  Start-Sleep -Milliseconds 300
  Pump-UI

  $py = Find-Python
  if (-not $py) { Fail "Python not found" }

  $cmd = $py.File
  $args = ""
  if ($py.Prefix -ne "") { $args += "$($py.Prefix) " }
  $args += "-m jupyter lab --no-browser --port=$Port --notebook-dir=""$StartDir"" --NotebookApp.token= --NotebookApp.password="

  Log "Starting Jupyter"
  Start-Process -WindowStyle Hidden -WorkingDirectory $StartDir -FilePath $cmd -ArgumentList $args | Out-Null

  if (-not (WaitUp $Port 12000)) { Fail "Jupyter didn't start" }

  # Close loading window now that the port is up
  try { $win.Close() } catch { }
  $win = $null

  $e1 = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
  $e2 = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
  $browser = $null
  if (Test-Path $e1) { $browser = $e1 } elseif (Test-Path $e2) { $browser = $e2 }

  $url = "http://127.0.0.1:$Port/lab"
  Log "Opening $url"

  if ($browser) {
    Start-Process -FilePath $browser -ArgumentList "--app=$url --new-window --start-maximized --disable-features=TranslateUI --disable-sync" | Out-Null
  } else {
    Start-Process $url | Out-Null
  }

  Log "DONE"
}
catch {
  try { if ($win) { $win.Close() } } catch { }
  Fail ("Unhandled: " + $_.Exception.Message)
}
