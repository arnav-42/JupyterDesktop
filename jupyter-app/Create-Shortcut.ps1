# Create-Shortcut.ps1
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$vbs = Join-Path $here "launch_jupyter_app.vbs"
$ico = Join-Path $here "jupyter_lab_icon.ico"

if (-not (Test-Path $vbs)) { throw "Missing: $vbs" }

$wscript = Join-Path $env:WINDIR "System32\wscript.exe"
if (-not (Test-Path $wscript)) { throw "Missing: $wscript" }

$shortcutPath = Join-Path $here "Jupyter Lab.lnk"

$wsh = New-Object -ComObject WScript.Shell
$s = $wsh.CreateShortcut($shortcutPath)

$s.TargetPath = $wscript
# //nologo prevents the Windows Script Host banner in some environments
$s.Arguments = "//nologo `"$vbs`""
$s.WorkingDirectory = $here

if (Test-Path $ico) {
  $s.IconLocation = $ico
}

$s.WindowStyle = 1
$s.Save()

Write-Host "Created: $shortcutPath"
