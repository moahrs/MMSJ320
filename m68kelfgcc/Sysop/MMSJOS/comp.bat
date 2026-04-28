@echo off
setlocal
cd /d %~dp0
call build_mmsjos.bat %*
exit /b %errorlevel%
