@echo off
rem Apply patches required for building

cd develop/src
if exist c:\vagrant\patches\windows\*.diff (
    echo Applying patches...

    for /f "tokens=*" %%s in ('dir /b c:\vagrant\patches\windows\*.diff ^| sort') do (
        echo Applying %%s
        call git apply --exclude="*.png" c:\vagrant\patches\windows\%%s
    )
) else (
    echo No patches found to apply.
)

echo Exchanging chromium.ico
copy /y c:\vagrant\scripts\windows\iridium.ico chrome\app\theme\chromium\win\chromium.ico >NUL
copy /y c:\vagrant\scripts\windows\chrome-logo-faded.png chrome\browser\resources\chrome-logo-faded.png >NUL
