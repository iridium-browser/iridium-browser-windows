@echo off
rem Compile release distribution packages

cd develop

if "%1" == "x64" (
    echo Compiling 64bit installer...
    ninja -C src\out\Release_x64 mini_installer
) else (
    echo Compiling 32bit installer...
    ninja -C src\out\Release mini_installer
)

echo "Copying compiled files..."

set TODAY=
for /f "skip=1" %%d in ('wmic os get localdatetime') do if not defined TODAY set TODAY=%%d
if not exist "C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%" (
    mkdir C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%
)
if "%1" == "x64" (
    copy /y src\out\Release_x64\mini_installer.exe C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%\mini_installer_x64.exe
) else (
    copy /y src\out\Release\dist\mini_installer.exe C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%\mini_installer_x86.exe
)
