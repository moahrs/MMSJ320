@echo off
setlocal
cd /d %~dp0
call build_sheet.bat %*
exit /b %errorlevel%
