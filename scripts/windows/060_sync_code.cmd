@echo off
rem Checkout source code

cd develop/src

git tag -l "40.0.2214.111" | findstr "40.0.2214.111" >nul 2>&1
if not %errorlevel% == 0 (
    echo Fetching tag information...
    call git fetch --tags
)

echo Switching to release branch...
call git checkout -B iridium_release_branch tags/40.0.2214.111

echo Syncing source code...
call gclient sync --with_branch_heads --nohooks
