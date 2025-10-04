@echo off
setlocal enabledelayedexpansion

:: Configuración
set "APP_NAME=Conversor de Imágenes"
set "START_MENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
set "DESKTOP_DIR=%USERPROFILE%\Desktop"
set "EXE_NAME=ConversorImagenes.exe"
set "PYTHON_SCRIPT=gui_converter.py"

:: Mostrar encabezado
echo ===================================================
echo    INSTALADOR DE %APP_NAME%
echo ===================================================
echo.

echo Verificando Python...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python no está instalado. Por favor instala Python 3.8 o superior.
    echo Visita: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Instalando dependencias...
python -m pip install --upgrade pip
python -m pip install pillow pyinstaller

if not exist "%PYTHON_SCRIPT%" (
    echo Error: No se encontró el archivo %PYTHON_SCRIPT%
    pause
    exit /b 1
)

echo Creando ejecutable...
python -m PyInstaller --onefile --windowed --noconsole --name "%EXE_NAME%" "%PYTHON_SCRIPT%"

if not exist "dist\%EXE_NAME%" (
    echo Error al crear el ejecutable.
    pause
    exit /b 1
)

echo Creando accesos directos...
if not exist "%START_MENU_DIR%" mkdir "%START_MENU_DIR%"
copy "dist\%EXE_NAME%" "%START_MENU_DIR%\%EXE_NAME%" >nul
copy "dist\%EXE_NAME%" "%DESKTOP_DIR%\%EXE_NAME%" >nul

echo.
echo ===================================================
echo    INSTALACIÓN COMPLETADA
echo ===================================================
echo.
echo %APP_NAME% se ha instalado correctamente.
echo.
echo Accesos directos creados en:
echo - Menú de Inicio: %START_MENU_DIR%
echo - Escritorio: %DESKTOP_DIR%
echo.
pause
