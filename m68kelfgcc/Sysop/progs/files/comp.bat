@echo off
setlocal
cd /d %~dp0
call build_files.bat %*
exit /b %errorlevel%
