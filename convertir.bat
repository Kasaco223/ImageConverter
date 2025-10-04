@echo off
setlocal enabledelayedexpansion

:: Verificar si Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Python no está instalado o no está en el PATH.
    echo Por favor, instala Python desde https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Verificar si Pillow está instalado
python -c "import PIL" 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Instalando Pillow...
    pip install pillow
    if %ERRORLEVEL% NEQ 0 (
        echo Error al instalar Pillow. Intenta instalar manualmente con: pip install pillow
        pause
        exit /b 1
    )
)

:: Configuración por defecto
set INPUT_FOLDER=input
set OUTPUT_FOLDER=output
set QUALITY=80
set RECURSIVE=

:: Menú de opciones
:menu
cls
echo ===================================
echo    CONVERSOR DE IMAGENES A WEBP
echo ===================================
echo.
echo 1. Convertir imagenes en la carpeta 'input' a 'output'
echo 2. Especificar carpetas de entrada y salida
echo 3. Cambiar calidad (actual: %QUALITY%)
echo 4. Habilitar/Deshabilitar busqueda en subcarpetas (actual: %RECURSIVE:1=Habilitado:0=Deshabilitado%)
echo 5. Salir
echo.
set /p opcion="Seleccione una opcion (1-5): "

goto opcion%opcion%

:opcion1
    echo.
    echo Convirtiendo imagenes...
    python convert_to_avif.py %INPUT_FOLDER% -o %OUTPUT_FOLDER% -q %QUALITY% %RECURSIVE%
    echo.
    pause
goto menu

:opcion2
    echo.
    set /p INPUT_FOLDER="Carpeta de entrada [%INPUT_FOLDER%]: "
    set /p OUTPUT_FOLDER="Carpeta de salida [%OUTPUT_FOLDER%]: "
    
    :: Si no se ingresa nada, mantener el valor por defecto
    if "!INPUT_FOLDER!"=="" set INPUT_FOLDER=input
    if "!OUTPUT_FOLDER!"=="" set OUTPUT_FOLDER=output
    
    echo Configuracion guardada.
    timeout /t 2 >nul
goto menu

:opcion3
    echo.
    set /p NEW_QUALITY="Nivel de calidad (1-100) [%QUALITY%]: "
    
    :: Validar que sea un número entre 1 y 100
    echo !NEW_QUALITY!| findstr /r "^[1-9][0-9]*$" >nul
    if %ERRORLEVEL% EQU 0 (
        if !NEW_QUALITY! GEQ 1 if !NEW_QUALITY! LEQ 100 (
            set QUALITY=!NEW_QUALITY!
            echo Calidad actualizada a: %QUALITY%
        ) else (
            echo Error: La calidad debe estar entre 1 y 100
        )
    ) else (
        echo Error: Ingrese un numero valido
    )
    
    timeout /t 2 >nul
goto menu

:opcion4
    if "%RECURSIVE%"=="-r" (
        set RECURSIVE=
    ) else (
        set RECURSIVE=-r
    )
    echo Busqueda en subcarpetas: %RECURSIVE:1=Habilitado:0=Deshabilitado%
    timeout /t 1 >nul
goto menu

:opcion5
    exit /b 0

:opcion
    echo Opcion no valida. Intente de nuevo.
    timeout /t 2 >nul
goto menu
