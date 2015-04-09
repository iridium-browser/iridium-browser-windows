@echo off
rem Determine root folder of script (without trailing backslash)
set ROOT=%~dp0
set ROOT=%ROOT:~0,-1%

rem Some commands we will be using below
set CMD_7ZA=%ROOT%\..\7za.exe
set CMD_HEAT=%ROOT%\wix39-binaries\heat.exe
set CMD_CANDLE=%ROOT%\wix39-binaries\candle.exe
set CMD_LIGHT=%ROOT%\wix39-binaries\light.exe

set SOURCE_FILE=%1
if "%SOURCE_FILE%" == "" (
    echo USAGE: %0 ^<chrome.7z^>
    exit /b 1
)
if not exist "%SOURCE_FILE%" (
    echo Source file "%SOURCE_FILE%" does not exist
    exit /b 1
)

set VERSION=%2
if "%VERSION%" == "" (
    set VERSION=0.0
)

set OUTPUT=%3
if "%OUTPUT%" == "" (
    set OUTPUT="%ROOT%\iridiumbrowser-%VERSION%.msi"
)

goto main

rem function :extract filename destination
:extract
"%CMD_7ZA%" x -y -o"%~2" "%~1" > NUL
goto :eof


:main

if not exist "%ROOT%\wix39-binaries" (
    echo Fetching WiX Toolset
    PowerShell Invoke-WebRequest -Uri '"http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=wix&DownloadId=1421697&FileTime=130661188723230000&Build=20983"' -OutFile "%ROOT%\wix39-binaries.zip"
    call :extract "%ROOT%\wix39-binaries.zip" "%ROOT%\wix39-binaries"
)

if exist "%ROOT%\chrome-source" (
    echo Cleaning up previous source folder
    rmdir /s /q "%ROOT%\chrome-source" > NUL
)
echo Extracting %SOURCE_FILE%
call :extract "%SOURCE_FILE%" "%ROOT%\chrome-source"
if exist "%ROOT%\chrome-source\chrome.7z" (
    rem Source file was "chrome.packed.7z"
    echo Extracting chrome.7z
    call :extract "%ROOT%\chrome-source\chrome.7z" "%ROOT%\chrome-source"
)
set SOURCE_ROOT=%ROOT%\chrome-source\Chrome-bin
if not exist "%SOURCE_ROOT%" (
    echo Source file did not contain folder "Chrome-bin", please check
    exit /b 1
)

set COMMON_ARGS=-nologo -wx

echo Generating file lists
"%CMD_HEAT%" dir "%SOURCE_ROOT%" %COMMON_ARGS% -ag -dr INSTALLDIR -var var.SourceRoot -sreg -srd -cg IridiumFiles -out "%ROOT%\iridium-files.wxs" -t "%ROOT%\update-files.xsl"
if not %errorlevel% == 0 (
    echo Failed, please check errors above
    exit /b 1
)

echo Processing WXS scripts
"%CMD_CANDLE%" %COMMON_ARGS% -d"SourceRoot=%SOURCE_ROOT%" -dVersion=%VERSION% -o "%ROOT%\\" "%ROOT%\iridium.wxs" "%ROOT%\iridium-files.wxs"
if not %errorlevel% == 0 (
    echo Failed, please check errors above
    exit /b 1
)

echo Creating installer for version %VERSION%
"%CMD_LIGHT%" %COMMON_ARGS% -ext WixUIExtension -ext WixUtilExtension -o "%OUTPUT%" "%ROOT%\iridium.wixobj" "%ROOT%\iridium-files.wixobj"
if not %errorlevel% == 0 (
    echo Failed, please check errors above
    exit /b 1
)
