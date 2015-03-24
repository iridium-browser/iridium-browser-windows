@echo off

if not exist "C:\Users\vagrant\depot_tools\gclient.bat" (
    echo Fetching depot_tools...
    PowerShell Invoke-WebRequest https://src.chromium.org/svn/trunk/tools/depot_tools.zip -OutFile C:\Users\vagrant\depot_tools.zip
    C:\vagrant\scripts\windows\7za.exe x -y -oC:\Users\vagrant C:\Users\vagrant\depot_tools.zip > NUL
    SETX PATH "%PATH%;C:\Users\vagrant\depot_tools" > NUL
    SETX DEPOT_TOOLS_WIN_TOOLCHAIN 0 > NUL
    call C:\Users\vagrant\depot_tools\gclient --version
) else (
    echo depot_tools already installed
)
