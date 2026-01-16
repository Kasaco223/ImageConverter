@echo off
setlocal
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
    echo Error al crear el ejecutable. Verifica los mensajes de error anteriores.
    pause
    exit /b 1
)

:: Generar script Python
echo Generando código fuente...
echo import tkinter as tk > "%SCRIPT_NAME%"
echo from tkinter import ttk, filedialog, messagebox >> "%SCRIPT_NAME%"
echo from PIL import Image, ImageTk >> "%SCRIPT_NAME%"
echo import os >> "%SCRIPT_NAME%"
echo import shutil >> "%SCRIPT_NAME%"
echo import sys >> "%SCRIPT_NAME%"
echo from pathlib import Path >> "%SCRIPT_NAME%"
echo from datetime import datetime, timedelta, timezone >> "%SCRIPT_NAME%"
echo import time >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo def get_colombia_timestamp(): >> "%SCRIPT_NAME%"
echo     now_utc = datetime.now(timezone.utc) >> "%SCRIPT_NAME%"
echo     colombia_offset = timezone(timedelta(hours=-5)) >> "%SCRIPT_NAME%"
echo     now_colombia = now_utc.astimezone(colombia_offset) >> "%SCRIPT_NAME%"
echo     return now_colombia.strftime("%%H%%M%%d%%m%%Y") >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo def get_custom_filename(original_filename, ext): >> "%SCRIPT_NAME%"
echo     name_without_ext = os.path.splitext(original_filename)[0] >> "%SCRIPT_NAME%"
echo     timestamp = get_colombia_timestamp() >> "%SCRIPT_NAME%"
echo     return f"{name_without_ext}_K_{timestamp}{ext}" >> "%SCRIPT_NAME%"
echo. >> "%SCRIPT_NAME%"
echo class ImageConverterApp: >> "%SCRIPT_NAME%"
echo     def __init__(self, root): >> "%SCRIPT_NAME%"
echo         self.root = root >> "%SCRIPT_NAME%"
echo         self.root.title("Conversor de Imágenes") >> "%SCRIPT_NAME%"
echo         self.root.geometry("800x600") >> "%SCRIPT_NAME%"
echo         self.root.minsize(700, 500) >> "%SCRIPT_NAME%"
echo         self.quality = tk.IntVar(value=80) >> "%SCRIPT_NAME%"
echo         self.output_format = tk.StringVar(value="webp") >> "%SCRIPT_NAME%"
echo         self.files_to_convert = [] >> "%SCRIPT_NAME%"
echo         self.output_dir = os.path.join(os.path.expanduser("~"), "Imágenes Comprimidas") >> "%SCRIPT_NAME%"
echo         os.makedirs(self.output_dir, exist_ok=True) >> "%SCRIPT_NAME%"
echo         self.style = ttk.Style() >> "%SCRIPT_NAME%"
echo         self.style.configure('TFrame', background='#f0f0f0') >> "%SCRIPT_NAME%"
echo         self.style.configure('TLabel', background='#f0f0f0') >> "%SCRIPT_NAME%"
echo         self.style.configure('TButton', padding=5) >> "%SCRIPT_NAME%"
echo         self.main_frame = ttk.Frame(root, padding="10") >> "%SCRIPT_NAME%"
echo         self.main_frame.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.drop_frame = ttk.LabelFrame(self.main_frame, text="Arrastra imágenes aquí", padding="20") >> "%SCRIPT_NAME%"
echo         self.drop_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.drop_label = ttk.Label(self.drop_frame, text="Arrastra y suelta imágenes aquí\no haz clic para seleccionar", justify=tk.CENTER) >> "%SCRIPT_NAME%"
echo         self.drop_label.pack(expand=True) >> "%SCRIPT_NAME%"
echo         self.controls_frame = ttk.Frame(self.main_frame) >> "%SCRIPT_NAME%"
echo         self.controls_frame.pack(fill=tk.X, pady=(0, 10)) >> "%SCRIPT_NAME%"
echo         ttk.Label(self.controls_frame, text="Calidad:").pack(side=tk.LEFT, padx=(0, 5)) >> "%SCRIPT_NAME%"
echo         self.quality_scale = ttk.Scale(self.controls_frame, from_=1, to=100, orient=tk.HORIZONTAL, variable=self.quality, command=lambda v: self.quality_var.set(f"{int(float(v))}%%")) >> "%SCRIPT_NAME%"
echo         self.quality_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.quality_var = tk.StringVar(value=f"{self.quality.get()}%%") >> "%SCRIPT_NAME%"
echo         ttk.Label(self.controls_frame, textvariable=self.quality_var, width=5).pack(side=tk.LEFT) >> "%SCRIPT_NAME%"
echo         ttk.Label(self.controls_frame, text="Formato:").pack(side=tk.LEFT, padx=(10, 5)) >> "%SCRIPT_NAME%"
echo         self.format_menu = ttk.Combobox(self.controls_frame, textvariable=self.output_format, values=["webp", "jpg", "png"], state="readonly", width=8) >> "%SCRIPT_NAME%"
echo         self.format_menu.pack(side=tk.LEFT, padx=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.convert_btn = ttk.Button(self.controls_frame, text="Convertir", command=self.convert_images, style="Accent.TButton") >> "%SCRIPT_NAME%"
echo         self.convert_btn.pack(side=tk.RIGHT) >> "%SCRIPT_NAME%"
echo         self.progress = ttk.Progressbar(self.main_frame, orient=tk.HORIZONTAL, length=100, mode='determinate') >> "%SCRIPT_NAME%"
echo         self.progress.pack(fill=tk.X, pady=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.log_frame = ttk.LabelFrame(self.main_frame, text="Registro", padding="5") >> "%SCRIPT_NAME%"
echo         self.log_frame.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.log_text = tk.Text(self.log_frame, height=10, wrap=tk.WORD, state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo         self.log_text.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.drop_frame.drop_target_register('DND_Files') >> "%SCRIPT_NAME%"
echo         self.drop_frame.dnd_bind('^<^<Drop^>^>', self.on_drop) >> "%SCRIPT_NAME%"
echo         self.drop_frame.bind('<Button-1>', self.on_click) >> "%SCRIPT_NAME%"
echo         self.style.configure('Accent.TButton', background='#4CAF50', foreground='white') >> "%SCRIPT_NAME%"
echo         self.log("Listo para convertir imágenes. Arrastra y suelta archivos o haz clic para seleccionar.") >> "%SCRIPT_NAME%"
echo     def log(self, message): >> "%SCRIPT_NAME%"
echo         self.log_text.config(state=tk.NORMAL) >> "%SCRIPT_NAME%"
echo         self.log_text.insert(tk.END, message + "\n") >> "%SCRIPT_NAME%"
echo         self.log_text.see(tk.END) >> "%SCRIPT_NAME%"
echo         self.log_text.config(state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo     def on_drop(self, event): >> "%SCRIPT_NAME%"
echo         files = self.root.tk.splitlist(event.data) >> "%SCRIPT_NAME%"
echo         self.process_files(files) >> "%SCRIPT_NAME%"
echo     def on_click(self, event): >> "%SCRIPT_NAME%"
echo         files = filedialog.askopenfilenames(title="Seleccionar imágenes", filetypes=(("Imágenes", "*.jpg *.jpeg *.png *.webp *.bmp *.tiff"), ("Todos los archivos", "*.*"))) >> "%SCRIPT_NAME%"
echo         if files: self.process_files(files) >> "%SCRIPT_NAME%"
echo     def process_files(self, files): >> "%SCRIPT_NAME%"
echo         supported_formats = ('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff') >> "%SCRIPT_NAME%"
echo         new_files = [] >> "%SCRIPT_NAME%"
echo         for file_path in files: >> "%SCRIPT_NAME%"
echo             ext = os.path.splitext(file_path)[1].lower() >> "%SCRIPT_NAME%"
echo             if ext in supported_formats: new_files.append(file_path) >> "%SCRIPT_NAME%"
echo         if not new_files: >> "%SCRIPT_NAME%"
echo             messagebox.showwarning("Sin archivos válidos", "No se encontraron archivos de imagen válidos.") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         self.files_to_convert = list(set(self.files_to_convert + new_files)) >> "%SCRIPT_NAME%"
echo         self.update_drop_label() >> "%SCRIPT_NAME%"
echo     def update_drop_label(self): >> "%SCRIPT_NAME%"
echo         if not self.files_to_convert: >> "%SCRIPT_NAME%"
echo             self.drop_label.config(text="Arrastra imágenes aquí\no haz clic para seleccionar") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         file_count = len(self.files_to_convert) >> "%SCRIPT_NAME%"
echo         if file_count == 1: >> "%SCRIPT_NAME%"
echo             filename = os.path.basename(self.files_to_convert[0]) >> "%SCRIPT_NAME%"
echo             if len(filename) ^> 30: filename = filename[:15] + "..." + filename[-15:] >> "%SCRIPT_NAME%"
echo             self.drop_label.config(text=f"1 archivo listo para convertir:\n{filename}") >> "%SCRIPT_NAME%"
echo         else: >> "%SCRIPT_NAME%"
echo             self.drop_label.config(text=f"{file_count} archivos listos para convertir") >> "%SCRIPT_NAME%"
echo     def convert_images(self): >> "%SCRIPT_NAME%"
echo         if not self.files_to_convert: >> "%SCRIPT_NAME%"
echo             messagebox.showinfo("Sin archivos", "No hay archivos para convertir.") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         output_format = self.output_format.get().lower() >> "%SCRIPT_NAME%"
echo         if output_format == 'jpg': output_format = 'jpeg' >> "%SCRIPT_NAME%"
echo         quality = self.quality.get() >> "%SCRIPT_NAME%"
echo         total_files = len(self.files_to_convert) >> "%SCRIPT_NAME%"
echo         converted_count = 0 >> "%SCRIPT_NAME%"
echo         output_dir = self.output_dir >> "%SCRIPT_NAME%"
echo         self.convert_btn.config(state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo         self.progress["maximum"] = total_files >> "%SCRIPT_NAME%"
echo         self.progress["value"] = 0 >> "%SCRIPT_NAME%"
echo         for i, input_path in enumerate(self.files_to_convert, 1): >> "%SCRIPT_NAME%"
echo             try: >> "%SCRIPT_NAME%"
echo                 filename = os.path.basename(input_path) >> "%SCRIPT_NAME%"
echo                 ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'} >> "%SCRIPT_NAME%"
echo                 ext = ext_map.get(output_format, '.' + output_format) >> "%SCRIPT_NAME%"
echo                 output_filename = get_custom_filename(filename, ext) >> "%SCRIPT_NAME%"
echo                 output_path = os.path.join(output_dir, output_filename) >> "%SCRIPT_NAME%"
echo                 self.log(f"Convirtiendo {i}/{total_files}: {filename} -> {output_filename}") >> "%SCRIPT_NAME%"
echo                 self.progress["value"] = i >> "%SCRIPT_NAME%"
echo                 self.root.update_idletasks() >> "%SCRIPT_NAME%"
echo                 with Image.open(input_path) as img: >> "%SCRIPT_NAME%"
echo                     if output_format == 'jpeg' and img.mode in ('RGBA', 'LA'): >> "%SCRIPT_NAME%"
echo                         background = Image.new('RGB', img.size, (255, 255, 255)) >> "%SCRIPT_NAME%"
echo                         background.paste(img, mask=img.split()[-1]) >> "%SCRIPT_NAME%"
echo                         img = background >> "%SCRIPT_NAME%"
echo                     elif img.mode != 'RGB' and output_format == 'jpeg': >> "%SCRIPT_NAME%"
echo                         img = img.convert('RGB') >> "%SCRIPT_NAME%"
echo                     save_args = {'quality': quality} >> "%SCRIPT_NAME%"
echo                     if output_format == 'webp': save_args['method'] = 6 >> "%SCRIPT_NAME%"
echo                     elif output_format == 'png': >> "%SCRIPT_NAME%"
echo                         save_args.pop('quality', None) >> "%SCRIPT_NAME%"
echo                         save_args['optimize'] = True >> "%SCRIPT_NAME%"
echo                     img.save(output_path, format=output_format.upper(), **save_args) >> "%SCRIPT_NAME%"
echo                 converted_count += 1 >> "%SCRIPT_NAME%"
echo             except Exception as e: >> "%SCRIPT_NAME%"
echo                 self.log(f"Error al convertir {os.path.basename(input_path)}: {str(e)}") >> "%SCRIPT_NAME%"
echo         self.log(f"\nConversión completada: {converted_count} de {total_files} archivos convertidos.") >> "%SCRIPT_NAME%"
echo         self.log(f"Los archivos se guardaron en: {output_dir}") >> "%SCRIPT_NAME%"
echo         self.files_to_convert = [] >> "%SCRIPT_NAME%"
echo         self.update_drop_label() >> "%SCRIPT_NAME%"
echo         self.convert_btn.config(state=tk.NORMAL) >> "%SCRIPT_NAME%"
echo         if converted_count ^> 0: >> "%SCRIPT_NAME%"
echo             if messagebox.askyesno("Conversión completada", f"Se convirtieron {converted_count} archivos.\n¿Deseas abrir la carpeta de destino?"): >> "%SCRIPT_NAME%"
echo                 os.startfile(output_dir) >> "%SCRIPT_NAME%"
echo def main(): >> "%SCRIPT_NAME%"
echo     root = tk.Tk() >> "%SCRIPT_NAME%"
echo     app = ImageConverterApp(root) >> "%SCRIPT_NAME%"
echo     root.mainloop() >> "%SCRIPT_NAME%"
echo if __name__ == "__main__": >> "%SCRIPT_NAME%"
echo     main() >> "%SCRIPT_NAME%"

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

:: Crear carpetas de trabajo
if not exist "input" mkdir "input"
if not exist "output" mkdir "output"

:: Limpiar script generado
del /f /q "%SCRIPT_NAME%" >nul 2>&1

:: Crear archivo de desinstalación
echo Creando desinstalador...
echo @echo off > "uninstall.bat"
echo echo Eliminando archivos del programa... >> "uninstall.bat"
echo if exist "%EXE_NAME%" del /f /q "%EXE_NAME%" >> "uninstall.bat"
echo if exist "input" rmdir /s /q "input" >> "uninstall.bat"
echo if exist "output" rmdir /s /q "output" >> "uninstall.bat"
echo echo Desinstalación completada. >> "uninstall.bat"
echo pause >> "uninstall.bat"
echo del "uninstall.bat" >> "uninstall.bat"

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
echo Se han creado las siguientes carpetas:
echo - input: Coloca aquí las imágenes a convertir.
echo - output: Aquí aparecerán las imágenes convertidas.
echo.
echo Para ejecutar el programa, abre "%EXE_NAME%".
echo.
echo Para desinstalar, ejecuta "uninstall.bat".
echo.
pause

exit /b 0
