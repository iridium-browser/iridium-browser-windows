@echo off
rem Apply patches required for building

cd develop/src
echo Applying patches...

for /f "tokens=*" %%s in ('dir /b c:\vagrant\patches\windows\*.diff ^| sort') do (
    echo Applying %%s
    call git apply --exclude="*.png" c:\vagrant\patches\windows\%%s
)
