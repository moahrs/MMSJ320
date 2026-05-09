@echo off
setlocal
cd /d %~dp0
call build_mcalc.bat %*
exit /b %errorlevel%
