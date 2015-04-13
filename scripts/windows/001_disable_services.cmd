@echo off

sc config wsearch start= disabled
net stop wsearch || set errorlevel = 0
