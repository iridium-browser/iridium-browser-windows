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

rem Ignore macro redefinitions for now, will get fixed upstream in iridium-browser
set CFLAGS=%CFLAGS% /wd4005
set CXXFLAGS=%CXXFLAGS% /wd4005

rem Link the browser into "chrome.dll" only instead of splitting up in
rem "chrome.dll" and "chrome_child.dll". This fixes a linker issue with finding
rem "chrome::ui_show_trace_alert" from "chrome_main.cc".
set GYP_DEFINES=%GYP_DEFINES% chrome_multiple_dll=0

cd develop/src

echo Executing gclient hooks...
call gclient runhooks
