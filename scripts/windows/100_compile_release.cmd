@echo off
rem Compile release distribution packages

cd develop

if "%1" == "x64" (
    echo Compiling 64bit installer...
    ninja -C src\out\Release_x64 chrome.7z
) else (
    echo Compiling 32bit installer...
    ninja -C src\out\Release chrome.7z
)
