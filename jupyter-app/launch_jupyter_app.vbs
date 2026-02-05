' launch_jupyter_app.vbs
Option Explicit

Dim fso, here, ps1, psExe, args, logFile, sh
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")

' Folder this .vbs lives in (works even if launched via shortcut)
here = fso.GetParentFolderName(WScript.ScriptFullName)

' Your PowerShell launcher (MUST exist in same folder)
ps1 = here & "\launch_jupyter_app.ps1"

' Write a quick log to TEMP so you can debug silent failures
logFile = sh.ExpandEnvironmentStrings("%TEMP%") & "\jupyter_vbs_launcher.log"

On Error Resume Next
Dim ts
Set ts = fso.OpenTextFile(logFile, 8, True) ' append
ts.WriteLine Now & "  VBS START"
ts.WriteLine Now & "  here=" & here
ts.WriteLine Now & "  ps1=" & ps1
ts.Close
On Error GoTo 0

If Not fso.FileExists(ps1) Then
  MsgBox "Cannot find: " & ps1 & vbCrLf & vbCrLf & _
         "Expected launch_jupyter_app.ps1 in the same folder as this VBS.", vbCritical, "Jupyter App"
  WScript.Quit 2
End If

psExe = sh.ExpandEnvironmentStrings("%WINDIR%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"

' IMPORTANT:
' - Set CurrentDirectory so relative assets (like PNG) resolve correctly
' - Use -STA for WPF loading window
sh.CurrentDirectory = here

args = "-NoProfile -ExecutionPolicy Bypass -STA -File " & Chr(34) & ps1 & Chr(34)

' 0 = hidden window, False = don't wait
sh.Run Chr(34) & psExe & Chr(34) & " " & args, 0, False
