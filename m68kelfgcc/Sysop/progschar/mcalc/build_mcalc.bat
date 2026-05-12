@echo off
setlocal

cd /d %~dp0

echo === Building MCALC (m68k-elf-gcc) ===
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
make flash
if errorlevel 1 exit /b 1
goto done

:do_ram
echo Modo: RAM (TEXT_ORIGIN=0x00000000)
make ram
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
echo Uso: build_mcalc.bat [MODE]
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
..\..\elftoexe mcalc.elf mcalc.exe
echo Artefatos gerados:
dir mcalc.elf mcalc.exe mcalc.map mcalc.lst
copy /Y mcalc.exe D:\PROJETOS\MMSJ320\HD_ATU\MCALC.EXE
copy /Y mcalc.exe F:\MCALC\MCALC.EXE
exit /b 0
