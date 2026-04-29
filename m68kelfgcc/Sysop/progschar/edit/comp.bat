@echo off
setlocal
cd /d %~dp0
call build_edit.bat %*
exit /b %errorlevel%
