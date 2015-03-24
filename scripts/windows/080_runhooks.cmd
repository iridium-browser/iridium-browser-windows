@echo off
rem Execute gclient hooks

if "%1" == "x64" (
    echo Preparing for 64bit build
    set GYP_DEFINES=remove_webcore_debug_symbols=1 host_arch=x64 target_arch=x64
) else (
    echo Preparing for 32bit build
    set GYP_DEFINES=remove_webcore_debug_symbols=1
)
set GYP_GENERATORS=ninja
set GYP_MSVS_VERSION=2013

rem See https://code.google.com/p/chromium/issues/detail?id=346399#c63
rem However we can't replace the "xtree" file from our non-privileged user
set CFLAGS=/wd4702
set CXXFLAGS=/wd4702

rem See https://codereview.chromium.org/720033003
rem Disable 4996 (deprecated functions in 8.1, these don't help us because we have to run on old OSs anyway)
set CFLAGS=%CFLAGS% /wd4996 /D_WINSOCK_DEPRECATED_NO_WARNINGS
set CXXFLAGS=%CXXFLAGS% /wd4996 /D_WINSOCK_DEPRECATED_NO_WARNINGS

rem Ignore macro redefinitions for now, will get fixed upstream in iridium-browser
set CFLAGS=%CFLAGS% /wd4005
set CXXFLAGS=%CXXFLAGS% /wd4005

cd develop/src

echo Executing gclient hooks...
call gclient runhooks
