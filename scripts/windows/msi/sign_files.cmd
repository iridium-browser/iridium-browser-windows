@echo off
rem Determine root folder of script (without trailing backslash)
set ROOT=%~dp0
set ROOT=%ROOT:~0,-1%

set SOURCE=%1
if "%SOURCE%" == "" (
    echo USAGE: %0 ^<path\to\files^>
    exit /b 1
)

set CERTIFICATE_FILE=C:\vagrant\codesign-certificate.spc
set PRIVATEKEY_FILE=C:\vagrant\codesign-key.pvk
set TIMESTAMP_URL=http://timestamp.verisign.com/scripts/timstamp.dll

if not exist "%CERTIFICATE_FILE%" (
    echo No certificate found at "%CERTIFICATE_FILE%", skipping signature.
    exit /b 0
)
if not exist "%PRIVATEKEY_FILE%" (
    echo No private key found at "%PRIVATEKEY_FILE%", skipping signature.
    exit /b 0
)

set SIGNFILE=%HOME%\signfile.exe
if not exist "%SIGNFILE%" (
    echo Compiling signature tool
    call "%VS120COMNTOOLS%\vsvars32.bat"
    cl /nologo /Fe:"%SIGNFILE%" /MT "%ROOT%\signfile.cc" crypt32.lib
    if not "%errorlevel%" == "0" (
        exit /b %errorlevel%
    )
)

set PLINK=%HOME%\plink.exe
if not exist "%PLINK%" (
    echo Fetching plink
    PowerShell Invoke-WebRequest -Uri '"http://the.earth.li/~sgtatham/putty/latest/x86/plink.exe"' -OutFile "%PLINK%"
)

goto main

rem function :signfile filename
:signfile
echo yes | "%HOME%\plink.exe" Administrator@localhost -pw vagrant "%SIGNFILE%" "%CERTIFICATE_FILE%" "%PRIVATEKEY_FILE%" "%~1" "%TIMESTAMP_URL%"
goto :eof

:signfolder
echo Sign folder contents "%~1"
if exist "%~1\*.exe" (
    for /f "tokens=*" %%G in ('dir /b "%~1\*.exe"') do (
        call :signfile "%~1\%%G"
    )
)
if exist "%~1\*.dll" (
    for /f "tokens=*" %%G in ('dir /b "%~1\*.dll"') do (
        call :signfile "%~1\%%G"
    )
)
goto :eof

:main

setlocal enableextensions
set ATTR=%~a1
set DIRATTR=%ATTR:~0,1%

if /I "%DIRATTR%" == "d" (
    call :signfolder "%SOURCE%"
    for /f "tokens=*" %%G in ('dir /b /s /a:d "%SOURCE%\*"') do (
        call :signfolder "%%G"
    )
) else (
    call :signfile "%SOURCE%"
)

