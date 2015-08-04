@echo off
setlocal
rem Execute gclient hooks

if "%1" == "x64" (
    echo Preparing for 64bit build
    set GYP_DEFINES=remove_webcore_debug_symbols=1 target_arch=x64
) else (
    echo Preparing for 32bit build
    set GYP_DEFINES=remove_webcore_debug_symbols=1
)
set GYP_GENERATORS=ninja
set GYP_MSVS_VERSION=2013

rem Enable proprietary codecs in Iridium (this adds various mime-types but
rem doesn't include the actual codecs).
set GYP_DEFINES=%GYP_DEFINES% proprietary_codecs=1

rem Always build FFmpeg as shared library so we can have both the regular and
rem the "-extra" package later.
set GYP_DEFINES=%GYP_DEFINES% build_ffmpegsumo=1 ffmpeg_component=shared_library

rem Ignore macro redefinitions for now, will get fixed upstream in iridium-browser
set CFLAGS=%CFLAGS% /wd4005
set CXXFLAGS=%CXXFLAGS% /wd4005

cd develop/src

echo Executing gclient hooks...
call gclient runhooks
