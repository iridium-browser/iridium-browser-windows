@echo off

if not exist "develop" (
    mkdir develop
    compact /c /q develop
)

cd develop
if not exist ".gclient" (
    echo Initializing gclient
    call fetch --nohooks chromium
) else (
    echo gclient already initialized
)
