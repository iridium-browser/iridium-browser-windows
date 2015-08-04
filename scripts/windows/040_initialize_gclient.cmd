@echo off

if not exist "develop" (
    mkdir develop
    compact /c /q develop
)

cd develop
if not exist "src" (
    echo Initializing gclient
    if exist ".gclient" (
        del .gclient > NUL
    )
    call fetch --nohooks chromium
) else (
    echo gclient already initialized
)
