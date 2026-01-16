@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: Configuración
set "APP_NAME=Conversor de Imágenes"
set "PYTHON_EXE=python.exe"
set "SCRIPT_NAME=%~dp0gui_converter.py"
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
:: Generar script Python
echo Generando código fuente...
(
echo import tkinter as tk
echo from tkinter import ttk, filedialog, messagebox
echo from PIL import Image, ImageTk
echo import os
echo import shutil
echo import sys
echo from pathlib import Path
echo from datetime import datetime, timedelta, timezone
echo import time
echo.
echo def get_colombia_timestamp^(^):
echo     now_utc = datetime.now^(timezone.utc^)
echo     colombia_offset = timezone^(timedelta^(hours=-5^)^)
echo     now_colombia = now_utc.astimezone^(colombia_offset^)
echo     return now_colombia.strftime^("%%H%%M%%d%%m%%Y"^)
echo.
echo def get_custom_filename^(original_filename, ext^):
echo     name_without_ext = os.path.splitext^(original_filename^)[0]
echo     timestamp = get_colombia_timestamp^(^)
echo     return f"{name_without_ext}_K_{timestamp}{ext}"
echo.
echo class ImageConverterApp:
echo     def __init__^(self, root^):
echo         self.root = root
echo         self.root.title^("Conversor de Imágenes"^)
echo         self.root.geometry^("800x600"^)
echo         self.root.minsize^(700, 500^)
echo         self.quality = tk.IntVar^(value=80^)
echo         self.output_format = tk.StringVar^(value="webp"^)
echo         self.files_to_convert = []
echo         self.output_dir = os.path.join^(os.path.expanduser^("~"^), "Imágenes Comprimidas"^)
echo         os.makedirs^(self.output_dir, exist_ok=True^)
echo         self.style = ttk.Style^(^)
echo         self.style.configure^('TFrame', background='#f0f0f0'^)
echo         self.style.configure^('TLabel', background='#f0f0f0'^)
echo         self.style.configure^('TButton', padding=5^)
echo         self.main_frame = ttk.Frame^(root, padding="10"^)
echo         self.main_frame.pack^(fill=tk.BOTH, expand=True^)
echo         self.drop_frame = ttk.LabelFrame^(self.main_frame, text="Arrastra imágenes aquí", padding="20"^)
echo         self.drop_frame.pack^(fill=tk.BOTH, expand=True, pady=^(0, 10^)^)
echo         self.drop_label = ttk.Label^(self.drop_frame, text="Arrastra y suelta imágenes aquí\no haz clic para seleccionar", justify=tk.CENTER^)
echo         self.drop_label.pack^(expand=True^)
echo         self.controls_frame = ttk.Frame^(self.main_frame^)
echo         self.controls_frame.pack^(fill=tk.X, pady=^(0, 10^)^)
echo         ttk.Label^(self.controls_frame, text="Calidad:"^).pack^(side=tk.LEFT, padx=^(0, 5^)^)
echo         self.quality_scale = ttk.Scale^(self.controls_frame, from_=1, to=100, orient=tk.HORIZONTAL, variable=self.quality, command=lambda v: self.quality_var.set^(f"{int^(float^(v^)^)}%%"^)^)
echo         self.quality_scale.pack^(side=tk.LEFT, fill=tk.X, expand=True, padx=^(0, 10^)^)
echo         self.quality_var = tk.StringVar^(value=f"{self.quality.get^(^)}%%"^)
echo         ttk.Label^(self.controls_frame, textvariable=self.quality_var, width=5^).pack^(side=tk.LEFT^)
echo         ttk.Label^(self.controls_frame, text="Formato:"^).pack^(side=tk.LEFT, padx=^(10, 5^)^)
echo         self.format_menu = ttk.Combobox^(self.controls_frame, textvariable=self.output_format, values=["webp", "jpg", "png"], state="readonly", width=8^)
echo         self.format_menu.pack^(side=tk.LEFT, padx=^(0, 10^)^)
echo         self.convert_btn = ttk.Button^(self.controls_frame, text="Convertir", command=self.convert_images, style="Accent.TButton"^)
echo         self.convert_btn.pack^(side=tk.RIGHT^)
echo         self.progress = ttk.Progressbar^(self.main_frame, orient=tk.HORIZONTAL, length=100, mode='determinate'^)
echo         self.progress.pack^(fill=tk.X, pady=^(0, 10^)^)
echo         self.log_frame = ttk.LabelFrame^(self.main_frame, text="Registro", padding="5"^)
echo         self.log_frame.pack^(fill=tk.BOTH, expand=True^)
echo         self.log_text = tk.Text^(self.log_frame, height=10, wrap=tk.WORD, state=tk.DISABLED^)
echo         self.log_text.pack^(fill=tk.BOTH, expand=True^)
echo         self.drop_frame.drop_target_register^('DND_Files'^)
echo         self.drop_frame.dnd_bind^('^<^<Drop^>^>', self.on_drop^)
echo         self.drop_frame.bind^('<Button-1>', self.on_click^)
echo         self.style.configure^('Accent.TButton', background='#4CAF50', foreground='white'^)
echo         self.log^("Listo para convertir imágenes. Arrastra y suelta archivos o haz clic para seleccionar."^)
echo     def log^(self, message^):
echo         self.log_text.config^(state=tk.NORMAL^)
echo         self.log_text.insert^(tk.END, message + "\n"^)
echo         self.log_text.see^(tk.END^)
echo         self.log_text.config^(state=tk.DISABLED^)
echo     def on_drop^(self, event^):
echo         files = self.root.tk.splitlist^(event.data^)
echo         self.process_files^(files^)
echo     def on_click^(self, event^):
echo         files = filedialog.askopenfilenames^(title="Seleccionar imágenes", filetypes=^(^("Imágenes", "*.jpg *.jpeg *.png *.webp *.bmp *.tiff"^), ^("Todos los archivos", "*.*"^)^)^)
echo         if files: self.process_files^(files^)
echo     def process_files^(self, files^):
echo         supported_formats = ^('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff'^)
echo         new_files = []
echo         for file_path in files:
echo             ext = os.path.splitext^(file_path^)[1].lower^(^)
echo             if ext in supported_formats: new_files.append^(file_path^)
echo         if not new_files:
echo             messagebox.showwarning^("Sin archivos válidos", "No se encontraron archivos de imagen válidos."^)
echo             return
echo         self.files_to_convert = list^(set^(self.files_to_convert + new_files^)^)
echo         self.update_drop_label^(^)
echo     def update_drop_label^(self^):
echo         if not self.files_to_convert:
echo             self.drop_label.config^(text="Arrastra imágenes aquí\no haz clic para seleccionar"^)
echo             return
echo         file_count = len^(self.files_to_convert^)
echo         if file_count == 1:
echo             filename = os.path.basename^(self.files_to_convert[0]^)
echo             if len^(filename^) ^> 30: filename = filename[:15] + "..." + filename[-15:]
echo             self.drop_label.config^(text=f"1 archivo listo para convertir:\n{filename}"^)
echo         else:
echo             self.drop_label.config^(text=f"{file_count} archivos listos para convertir"^)
echo     def convert_images^(self^):
echo         if not self.files_to_convert:
echo             messagebox.showinfo^("Sin archivos", "No hay archivos para convertir."^)
echo             return
echo         output_format = self.output_format.get^(^).lower^(^)
echo         if output_format == 'jpg': output_format = 'jpeg'
echo         quality = self.quality.get^(^)
echo         total_files = len^(self.files_to_convert^)
echo         converted_count = 0
echo         output_dir = self.output_dir
echo         self.convert_btn.config^(state=tk.DISABLED^)
echo         self.progress["maximum"] = total_files
echo         self.progress["value"] = 0
echo         for i, input_path in enumerate^(self.files_to_convert, 1^):
echo             try:
echo                 filename = os.path.basename^(input_path^)
echo                 ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'}
echo                 ext = ext_map.get^(output_format, '.' + output_format^)
echo                 output_filename = get_custom_filename^(filename, ext^)
echo                 output_path = os.path.join^(output_dir, output_filename^)
echo                 self.log^(f"Convirtiendo {i}/{total_files}: {filename} -> {output_filename}"^)
echo                 self.progress["value"] = i
echo                 self.root.update_idletasks^(^)
echo                 with Image.open^(input_path^) as img:
echo                     if output_format == 'jpeg' and img.mode in ^('RGBA', 'LA'^):
echo                         background = Image.new^('RGB', img.size, ^(255, 255, 255^)^)
echo                         background.paste^(img, mask=img.split^(^)[-1]^)
echo                         img = background
echo                     elif img.mode != 'RGB' and output_format == 'jpeg':
echo                         img = img.convert^('RGB'^)
echo                     save_args = {'quality': quality}
echo                     if output_format == 'webp': save_args['method'] = 6
echo                     elif output_format == 'png':
echo                         save_args.pop^('quality', None^)
echo                         save_args['optimize'] = True
echo                     img.save^(output_path, format=output_format.upper^(^), **save_args^)
echo                 converted_count += 1
echo             except Exception as e:
echo                 self.log^(f"Error al convertir {os.path.basename(input_path)}: {str(e)}"^)
echo         self.log^(f"\nConversión completada: {converted_count} de {total_files} archivos convertidos."^)
echo         self.log^(f"Los archivos se guardaron en: {output_dir}"^)
echo         self.files_to_convert = []
echo         self.update_drop_label^(^)
echo         self.convert_btn.config^(state=tk.NORMAL^)
echo         if converted_count ^> 0:
echo             if messagebox.askyesno^("Conversión completada", f"Se convirtieron {converted_count} archivos.\n¿Deseas abrir la carpeta de destino?"^):
echo                 os.startfile^(output_dir^)
echo def main^(^):
echo     root = tk.Tk^(^)
echo     app = ImageConverterApp^(root^)
echo     root.mainloop^(^)
echo if __name__ == "__main__":
echo     main^(^)
) > "%SCRIPT_NAME%"

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
