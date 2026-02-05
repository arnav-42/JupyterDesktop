# JupyterDesktop
A launcher for a "desktop app" version for Jupyter

![demo](https://github.com/arnav-42/JupyterDesktop/blob/main/Media/launch.gif)

## FAQ
### Is this a desktop version of JupyterLab?
This is a collection of scripts that will allow you to launch JupyterLab in a Chromium browser using *app mode*. The "app" has its own icon, loading screen, window, etc, and in app mode, tabs and the searchbar aren't rendered. The terminal running JupyterLab is auto hidden to further the illusion.

An official version of JupyterLab for the desktop [exists](https://github.com/jupyterlab/jupyterlab-desktop), but it was retired a while ago and has currently has major security flaws, according to Project Jupyter.

### So why use this then?
Ever close the terminal running JupyterLab when you didn't mean to? Not possible with JupyterDesktop, as the terminal running the show is hidden. Furthermore, with searchbar and tabs hidden, and with an icon in the taskbar, it genuinely feels like a standalone IDE, clearing up the annoyance of digging through multiple tabs, or dealing with multiple web browser windows.

### If this a wrapper for the official JupyterLab, is it slower?
No. Since behind the hood it's running in Edge, it'll run at the same speed as if you had launched JupyterLab regularly. Plus Electron (what was used for the official Jupyter desktop application) is basically a web browser anyways.. kinda.



## Installation
- Download the scripts:
  - Option 1: Download the `jupyter-app` folder from above
  - Option 2: Install and unzip the latest release from the right sidebar
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
