@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "ROOT=%cd%"
set "NASM=%ROOT%\tools\nasm-2.16.03\nasm.exe"
set "GCC=gcc"

if not exist "%NASM%" (
  echo [!] NASM introuvable: %NASM%
  echo     Placez nasm.exe dans tools\ ou telechargez NASM 2.16+ win64.
  exit /b 1
)

where gcc >nul 2>&1
if errorlevel 1 (
  echo [!] gcc ^(MinGW^) introuvable dans le PATH.
  exit /b 1
)

if not exist obj mkdir obj
if not exist bin mkdir bin

echo == Assemblage GuiASM ==
"%NASM%" -f win64 -I"%~dp0include\\" -o obj\gui_core.obj    src\gui_core.asm
if errorlevel 1 goto :fail
"%NASM%" -f win64 -I"%~dp0include\\" -o obj\gui_widgets.obj src\gui_widgets.asm
if errorlevel 1 goto :fail
"%NASM%" -f win64 -I"%~dp0include\\" -o obj\gui_draw.obj    src\gui_draw.asm
if errorlevel 1 goto :fail
"%NASM%" -f win64 -I"%~dp0include\\" -o obj\gui_log.obj     src\gui_log.asm
if errorlevel 1 goto :fail
"%NASM%" -f win64 -I"%~dp0include\\" -o obj\demo.obj        examples\demo.asm
if errorlevel 1 goto :fail

"%NASM%" -f win64 -I"%~dp0include\\" -o obj\minimal.obj examples\minimal.asm
if errorlevel 1 goto :fail

echo == Linkage ==
"%GCC%" -mwindows -o bin\demo.exe ^
  obj\demo.obj obj\gui_core.obj obj\gui_widgets.obj obj\gui_draw.obj obj\gui_log.obj ^
  -luser32 -lgdi32 -lkernel32
if errorlevel 1 goto :fail

"%GCC%" -mwindows -o bin\minimal.exe ^
  obj\minimal.obj obj\gui_core.obj obj\gui_widgets.obj obj\gui_draw.obj obj\gui_log.obj ^
  -luser32 -lgdi32 -lkernel32
if errorlevel 1 goto :fail

echo.
echo [OK] bin\demo.exe
echo [OK] bin\minimal.exe
echo Lancez: bin\demo.exe
exit /b 0

:fail
echo.
echo [ECHEC] Compilation interrompue.
exit /b 1
