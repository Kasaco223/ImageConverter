@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: Configuración
set "APP_NAME=Conversor de Imágenes"
set "PYTHON_EXE=python.exe"
set "SCRIPT_NAME=gui_converter.py"
set "EXE_NAME=ConversorImagenes.exe"
set "SHORTCUT_NAME=%APP_NAME%.lnk"
set "START_MENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
set "DESKTOP_DIR=%USERPROFILE%\Desktop"
set "DIST_DIR=dist"
set "BUILD_DIR=build"
set "TEMP_DIR=%TEMP%\%RANDOM%"

:: Crear directorio temporal
mkdir "%TEMP_DIR%" 2>nul

:: Mostrar encabezado
echo ===================================================
echo    INSTALADOR DE %APP_NAME%
echo ===================================================
echo.

echo Verificando requisitos...
echo.

:: Verificar Python
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python no está instalado o no está en el PATH.
    echo Instalando Python...
    
    :: Descargar instalador de Python
    set "PYTHON_URL=https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe"
    
    echo Descargando Python 3.11.4...
    powershell -Command "& {$url = 'https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe'; $output = Join-Path $env:TEMP 'python_installer.exe'; (New-Object System.Net.WebClient).DownloadFile($url, $output); exit $LASTEXITCODE}" || (
        echo Error al descargar Python.
        echo Por favor, instala Python manualmente desde https://www.python.org/downloads/
        pause
        exit /b 1
    )
    
    echo Instalando Python...
    start /wait "" "%TEMP%\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del /f /q "%TEMP%\python_installer.exe" >nul 2>&1
    
    echo Python instalado correctamente.
    echo Por favor, cierra y vuelve a abrir el instalador para continuar.
    pause
    exit /b 0
)

:: Verificar e instalar dependencias
echo Instalando dependencias...

:: Actualizar pip
echo Actualizando pip...
%PYTHON_EXE% -m pip install --upgrade pip --no-warn-script-location
if %ERRORLEVEL% NEQ 0 (
    echo Error al actualizar pip. Continuando de todos modos...
)

:: Instalar dependencias
echo Instalando PyInstaller y Pillow...
%PYTHON_EXE% -m pip install pyinstaller pillow --no-warn-script-location
if %ERRORLEVEL% NEQ 0 (
    echo Error al instalar las dependencias.
    pause
    exit /b 1
)

echo.
echo Creando ejecutable...

:: Crear ejecutable con PyInstaller
echo Creando ejecutable con PyInstaller...
%PYTHON_EXE% -m PyInstaller --noconfirm --onefile --windowed --name="%EXE_NAME:~0,-4%" --icon=NONE "%SCRIPT_NAME%" --distpath "%TEMP_DIR%" --workpath "%TEMP_DIR%\build" --specpath "%TEMP_DIR%"

if not exist "%TEMP_DIR%\%EXE_NAME%" (
    echo Error al crear el ejecutable. Verifica los mensajes de error anteriores.
    pause
    exit /b 1
)

:: Mover el ejecutable al directorio actual
move /Y "%TEMP_DIR%\%EXE_NAME%" . >nul

:: Crear acceso directo
echo.
echo Creando accesos directos...

:: Crear directorio en el menú de inicio
if not exist "%START_MENU_DIR%" mkdir "%START_MENU_DIR%"

:: Crear directorio en el menú de inicio
if not exist "%START_MENU_DIR%" mkdir "%START_MENU_DIR%"

:: Copiar el ejecutable al menú de inicio
copy "%EXE_NAME%" "%START_MENU_DIR%\%EXE_NAME%" >nul

:: Copiar el ejecutable al escritorio
copy "%EXE_NAME%" "%DESKTOP_DIR%\%EXE_NAME%" >nul

:: Crear accesos directos
powershell -Command "
$WshShell = New-Object -comObject WScript.Shell;
$Shortcut = $WshShell.CreateShortcut('%START_MENU_DIR%\%SHORTCUT_NAME%');
$Shortcut.TargetPath = '%START_MENU_DIR%\%EXE_NAME%';
$Shortcut.WorkingDirectory = '%START_MENU_DIR%';
$Shortcut.IconLocation = '%SYSTEMROOT%\System32\imageres.dll,67';
$Shortcut.Description = '%APP_NAME%';
$Shortcut.Save()"

powershell -Command "
$WshShell = New-Object -comObject WScript.Shell;
$Shortcut = $WshShell.CreateShortcut('%DESKTOP_DIR%\%SHORTCUT_NAME%');
$Shortcut.TargetPath = '%DESKTOP_DIR%\%EXE_NAME%';
$Shortcut.WorkingDirectory = '%DESKTOP_DIR%';
$Shortcut.IconLocation = '%SYSTEMROOT%\System32\imageres.dll,67';
$Shortcut.Description = '%APP_NAME%';
$Shortcut.Save()"

:: Crear archivo de desinstalación
echo Creando desinstalador...
(
echo @echo off
echo setlocal enabledelayedexpansion

echo Eliminando archivos del programa...
if exist "%START_MENU_DIR%\%EXE_NAME%" (
    del /f /q "%START_MENU_DIR%\%EXE_NAME%"
)

if exist "%DESKTOP_DIR%\%EXE_NAME%" (
    del /f /q "%DESKTOP_DIR%\%EXE_NAME%"
)

echo Eliminando accesos directos...
if exist "%START_MENU_DIR%\%SHORTCUT_NAME%" (
    del /f /q "%START_MENU_DIR%\%SHORTCUT_NAME%"
)

if exist "%DESKTOP_DIR%\%SHORTCUT_NAME%" (
    del /f /q "%DESKTOP_DIR%\%SHORTCUT_NAME%"
)

if exist "%START_MENU_DIR%" (
    rmdir "%START_MENU_DIR%" 2>nul
)

echo Desinstalación completada.
pause
) > "uninstall.bat"

:: Copiar el desinstalador al menú de inicio
copy "uninstall.bat" "%START_MENU_DIR%\Desinstalar %APP_NAME%.bat" >nul

:: Limpiar archivos temporales
rmdir /s /q "%TEMP_DIR%" 2>nul

:: Mostrar mensaje de finalización
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
echo Para ejecutar el programa, usa cualquiera de los accesos directos creados.
echo.
echo Para desinstalar, ejecuta "Desinstalar %APP_NAME%.bat" desde el menú de inicio.
echo.
pause

exit /b 0
