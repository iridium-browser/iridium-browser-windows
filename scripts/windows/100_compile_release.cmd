@echo off
rem Compile release distribution packages

cd develop

if "%1" == "x64" (
    echo Compiling 64bit installer...
    set RELEASE_FOLDER=src\out\Release_x64
) else (
    echo Compiling 32bit installer...
    set RELEASE_FOLDER=src\out\Release
)

rem Need to delete old manifest files so they are not included in the installer
if exist %RELEASE_FOLDER%\*.manifest (
    del /q %RELEASE_FOLDER%\*.manifest
)
ninja -C %RELEASE_FOLDER% chrome.7z
