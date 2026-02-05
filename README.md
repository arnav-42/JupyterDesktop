# JupyterDesktop
A launcher for a "desktop app" version for Jupyter

![demo](https://github.com/arnav-42/JupyterDesktop/blob/main/Media/launch.gif)

## Installation
- Download the `jupyter-app` folder
- Open it, select `Create-Shortcut.ps1`, right click, and click *Run with Powershell*
- This will create the shortcut in the `jupyter-app` folder
- Drag this shortcut to your Desktop or wherever you'd like

![tutorial](https://github.com/arnav-42/JupyterDesktop/blob/main/Media/shortcut.gif)


## Requirements

* **Python 3.x** installed (either `py.exe` or `python.exe` must be available)
* **JupyterLab** installed (`pip install jupyterlab`)
* **Windows PowerShell**
* **Windows Script Host** (`wscript.exe`, enabled by default)
* (Optional) **Microsoft Edge** installed for opening JupyterLab in app mode
  Otherwise, your default browser will be used.
* Ability to run PowerShell scripts using:

  ```
  powershell -ExecutionPolicy Bypass -File ...
  ```


> [!Note]
> This launcher only works on **Windows 10 or Windows 11**.
> 
> It does not run on macOS or Linux.

---
