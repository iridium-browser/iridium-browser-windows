@echo off
rem Build .msi installer

cd "%HOME%\develop"

set VERSION=41.1
set OUTPUT=%CD%\iridiumbrowser-%VERSION%.msi

call c:\vagrant\scripts\windows\msi\build_msi.cmd src\out\Release\chrome.7z "%VERSION%" "%OUTPUT%"
if not %errorlevel% == 0 (
    exit /b 1
)

echo Copying compiled files...

set TODAY=
for /f "skip=1" %%d in ('wmic os get localdatetime') do if not defined TODAY set TODAY=%%d
if not exist "C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%" (
    mkdir C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%
)
copy /y "%OUTPUT%" C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6% >NUL
echo Done
