@echo off
setlocal
rem Build .msi installer

cd develop

set ARCH=%1
if "%ARCH%" == "" (
    set ARCH="x86"
)
set VERSION=44.0.0
set OUTPUT=%CD%\iridiumbrowser-%VERSION%-%ARCH%
if "%1" == "x64" (
    set RELEASE_FOLDER=src\out\Release_x64
) else (
    set RELEASE_FOLDER=src\out\Release
)

call c:\vagrant\scripts\windows\msi\build_msi.cmd %RELEASE_FOLDER%\chrome.7z "%VERSION%" "%OUTPUT%" %ARCH% %RELEASE_FOLDER%\ffmpeg-free.dll
if not %errorlevel% == 0 (
    exit /b 1
)

set OUTPUT_EXTRA=%CD%\iridiumbrowser-%VERSION%-extra-%ARCH%

call c:\vagrant\scripts\windows\msi\build_msi.cmd %RELEASE_FOLDER%\chrome.7z "%VERSION%" "%OUTPUT_EXTRA%" %ARCH% %RELEASE_FOLDER%\ffmpeg-extra.dll
if not %errorlevel% == 0 (
    exit /b 1
)

echo Copying compiled files...

set TODAY=
for /f "skip=1" %%d in ('wmic os get localdatetime') do if not defined TODAY set TODAY=%%d
if not exist "C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%" (
    mkdir C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6%
)
copy /y "%OUTPUT%.msi" C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6% >NUL
copy /y "%OUTPUT%.zip" C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6% >NUL
copy /y "%OUTPUT_EXTRA%.msi" C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6% >NUL
copy /y "%OUTPUT_EXTRA%.zip" C:\vagrant\build_result\%TODAY:~0,8%-%TODAY:~8,6% >NUL
echo Done
