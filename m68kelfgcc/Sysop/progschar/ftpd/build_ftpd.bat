@echo off
setlocal

cd /d %~dp0

echo === Building ftpd (m68k-elf-gcc) ===
where m68k-elf-gcc >nul 2>nul
if errorlevel 1 (
  echo ERRO: m68k-elf-gcc nao encontrado no PATH.
  exit /b 1
)

set "MODE=%~1"
set "CUSTOM_ORIGIN="

if "%MODE%"=="" set "MODE=ram"

if /I "%MODE%"=="flash" goto do_flash
if /I "%MODE%"=="ram" goto do_ram
if /I "%MODE%"=="all" goto do_ram
if /I "%MODE%"=="help" goto show_help
if /I "%MODE%"=="-h" goto show_help
if /I "%MODE%"=="--help" goto show_help

set "CUSTOM_ORIGIN=%MODE%"
if /I not "%CUSTOM_ORIGIN:~0,2%"=="0x" set "CUSTOM_ORIGIN=0x%CUSTOM_ORIGIN%"
goto do_custom

:do_flash
echo Modo: FLASH (TEXT_ORIGIN=0x00020000)
make -B flash
if errorlevel 1 exit /b 1
goto done

:do_ram
echo Modo: RAM (TEXT_ORIGIN=0x00000000)
make -B ram
if errorlevel 1 exit /b 1
goto done

:do_custom
echo Modo: CUSTOM (TEXT_ORIGIN=%CUSTOM_ORIGIN%)
make clean
if errorlevel 1 exit /b 1
make -B TEXT_ORIGIN=%CUSTOM_ORIGIN%
if errorlevel 1 exit /b 1
goto done

:show_help
echo.
echo Uso: build_ftpd.bat [MODE]
echo.
echo Modos:
echo   (default)  RAM mode (TEXT_ORIGIN=0x00000000)
echo   flash      Flash mode (TEXT_ORIGIN=0x00020000)
echo   ram        RAM mode
echo   all        Same as 'ram'
echo   0xXXXXXX   Custom origin address
echo   help       Show this help message
echo.
exit /b 0

:done

echo.
..\..\elftoexe ftpd.elf ftpd.exe
echo Artefatos gerados:
dir ftpd.elf ftpd.exe ftpd.map ftpd.lst
copy /Y ftpd.exe D:\PROJETOS\MMSJ320\HD_ATU\NETWRK\FTPD.EXE
copy /Y ftpd.exe F:\NETWRK\FTPD.EXE
exit /b 0
