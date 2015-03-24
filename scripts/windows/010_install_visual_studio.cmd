@echo off
rem Install requirements in Vagrant box

rem Check Vagrantfile for information on how to obtain
rem Visual Studio Community 2013 Update 4
if not exist "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\cl.exe" (
    echo Installing Visual Studio Community 2013 Update 4...
    PowerShell Start-Process -Wait -FilePath E:\vs_community.exe -ArgumentList /silent,/norestart,/Log,C:\Users\vagrant\vs_setup.log,/adminfile,C:\vagrant\scripts\windows\AdminDeployment.xml
) else (
    echo Visual Studio Community 2013 Update 4 already installed
)
