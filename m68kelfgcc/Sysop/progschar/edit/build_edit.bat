@echo off
setlocal

cd /d %~dp0

echo === Building EDIT (m68k-elf-gcc) ===
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
echo Modo: RAM (TEXT_ORIGIN=0x00870000)
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
echo Uso:
echo   build_edit.bat                ^(padrao: ram^)
echo   build_edit.bat ram            ^(usa 0x00870000^)
echo   build_edit.bat flash          ^(usa 0x00020000^)
echo   build_edit.bat 0x00004000     ^(origem customizada^)
echo   build_edit.bat 4000           ^(origem customizada^)
exit /b 0

:done

echo.
echo Artefatos gerados:
dir edit.elf edit.bin edit.map edit.lst
copy /Y edit.bin D:\PROJETOS\MMSJ320\HD_ATU\EDIT.BIN
copy /Y edit.bin F:\EDIT.BIN
exit /b 0
