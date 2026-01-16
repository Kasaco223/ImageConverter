@echo off
setlocal
cd /d "%~dp0"

:: Configuración
set "APP_NAME=Conversor de Imágenes"
set "PYTHON_EXE=python.exe"
set "SCRIPT_NAME=%~dp0gui_converter.py"
set "EXE_NAME=ConversorImagenes.exe"
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
echo         self.root.title("Conversor de Imágenes - Modo Oscuro") >> "%SCRIPT_NAME%"
echo         self.root.geometry("800x650") >> "%SCRIPT_NAME%"
echo         self.root.configure(bg='#1e1e1e') >> "%SCRIPT_NAME%"
echo         self.input_dir = tk.StringVar(value=os.path.join(os.getcwd(), "input")) >> "%SCRIPT_NAME%"
echo         self.output_dir = tk.StringVar(value=os.path.join(os.getcwd(), "output")) >> "%SCRIPT_NAME%"
echo         self.quality = tk.IntVar(value=80) >> "%SCRIPT_NAME%"
echo         self.output_format = tk.StringVar(value="webp") >> "%SCRIPT_NAME%"
echo         self.setup_styles() >> "%SCRIPT_NAME%"
echo         self.create_widgets() >> "%SCRIPT_NAME%"
echo     def setup_styles(self): >> "%SCRIPT_NAME%"
echo         style = ttk.Style() >> "%SCRIPT_NAME%"
echo         style.theme_use('clam') >> "%SCRIPT_NAME%"
echo         bg_color = '#1e1e1e' >> "%SCRIPT_NAME%"
echo         fg_color = '#ffffff' >> "%SCRIPT_NAME%"
echo         accent_color = '#4CAF50' >> "%SCRIPT_NAME%"
echo         style.configure('TFrame', background=bg_color) >> "%SCRIPT_NAME%"
echo         style.configure('TLabel', background=bg_color, foreground=fg_color, font=('Segoe UI', 10)) >> "%SCRIPT_NAME%"
echo         style.configure('TLabelframe', background=bg_color, foreground=fg_color) >> "%SCRIPT_NAME%"
echo         style.configure('TLabelframe.Label', background=bg_color, foreground=fg_color, font=('Segoe UI', 10, 'bold')) >> "%SCRIPT_NAME%"
echo         style.configure('TButton', padding=5, font=('Segoe UI', 10)) >> "%SCRIPT_NAME%"
echo         style.map('TButton', background=[('active', '#3d3d3d')], foreground=[('active', '#ffffff')]) >> "%SCRIPT_NAME%"
echo         style.configure('Accent.TButton', background=accent_color, foreground='white') >> "%SCRIPT_NAME%"
echo         style.map('Accent.TButton', background=[('active', '#45a049')]) >> "%SCRIPT_NAME%"
echo         style.configure('TEntry', fieldbackground='#3d3d3d', foreground='white', insertcolor='white') >> "%SCRIPT_NAME%"
echo         style.configure('TCombobox', fieldbackground='#3d3d3d', foreground='white', background='#3d3d3d') >> "%SCRIPT_NAME%"
echo     def create_widgets(self): >> "%SCRIPT_NAME%"
echo         main_frame = ttk.Frame(self.root, padding="20") >> "%SCRIPT_NAME%"
echo         main_frame.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         folder_frame = ttk.LabelFrame(main_frame, text=" Carpetas ", padding="15") >> "%SCRIPT_NAME%"
echo         folder_frame.pack(fill=tk.X, pady=(0, 20)) >> "%SCRIPT_NAME%"
echo         ttk.Label(folder_frame, text="Carpeta de Entrada:").grid(row=0, column=0, sticky=tk.W, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Entry(folder_frame, textvariable=self.input_dir, width=60).grid(row=0, column=1, padx=10, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Button(folder_frame, text="Buscar", command=self.browse_input).grid(row=0, column=2, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Label(folder_frame, text="Carpeta de Salida:").grid(row=1, column=0, sticky=tk.W, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Entry(folder_frame, textvariable=self.output_dir, width=60).grid(row=1, column=1, padx=10, pady=5) >> "%SCRIPT_NAME%"
echo         ttk.Button(folder_frame, text="Buscar", command=self.browse_output).grid(row=1, column=2, pady=5) >> "%SCRIPT_NAME%"
echo         controls_frame = ttk.LabelFrame(main_frame, text=" Ajustes de Conversión ", padding="15") >> "%SCRIPT_NAME%"
echo         controls_frame.pack(fill=tk.X, pady=(0, 20)) >> "%SCRIPT_NAME%"
echo         ttk.Label(controls_frame, text="Calidad:").pack(side=tk.LEFT, padx=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.quality_scale = ttk.Scale(controls_frame, from_=1, to=100, orient=tk.HORIZONTAL, variable=self.quality, command=self.update_quality_label) >> "%SCRIPT_NAME%"
echo         self.quality_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10)) >> "%SCRIPT_NAME%"
echo         self.quality_label = ttk.Label(controls_frame, text=f"{self.quality.get()}%%", width=5) >> "%SCRIPT_NAME%"
echo         self.quality_label.pack(side=tk.LEFT) >> "%SCRIPT_NAME%"
echo         ttk.Label(controls_frame, text="Formato:").pack(side=tk.LEFT, padx=(20, 10)) >> "%SCRIPT_NAME%"
echo         self.format_menu = ttk.Combobox(controls_frame, textvariable=self.output_format, values=["webp", "jpg", "png"], state="readonly", width=10) >> "%SCRIPT_NAME%"
echo         self.format_menu.pack(side=tk.LEFT) >> "%SCRIPT_NAME%"
echo         self.convert_btn = ttk.Button(main_frame, text="CONVERTIR TODO", command=self.convert_all, style="Accent.TButton") >> "%SCRIPT_NAME%"
echo         self.convert_btn.pack(fill=tk.X, pady=(0, 20)) >> "%SCRIPT_NAME%"
echo         self.progress = ttk.Progressbar(main_frame, orient=tk.HORIZONTAL, length=100, mode='determinate') >> "%SCRIPT_NAME%"
echo         self.progress.pack(fill=tk.X, pady=(0, 10)) >> "%SCRIPT_NAME%"
echo         log_frame = ttk.LabelFrame(main_frame, text=" Registro de Actividad ", padding="5") >> "%SCRIPT_NAME%"
echo         log_frame.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.log_text = tk.Text(log_frame, height=12, bg='#121212', fg='#00ff00', font=('Consolas', 10), borderwidth=0) >> "%SCRIPT_NAME%"
echo         self.log_text.pack(fill=tk.BOTH, expand=True) >> "%SCRIPT_NAME%"
echo         self.log("Listo. El programa buscará imágenes en la carpeta 'input' por defecto.") >> "%SCRIPT_NAME%"
echo     def update_quality_label(self, event): >> "%SCRIPT_NAME%"
echo         self.quality_label.config(text=f"{int(float(self.quality.get()))}%%") >> "%SCRIPT_NAME%"
echo     def browse_input(self): >> "%SCRIPT_NAME%"
echo         dir = filedialog.askdirectory(initialdir=self.input_dir.get()) >> "%SCRIPT_NAME%"
echo         if dir: self.input_dir.set(dir) >> "%SCRIPT_NAME%"
echo     def browse_output(self): >> "%SCRIPT_NAME%"
echo         dir = filedialog.askdirectory(initialdir=self.output_dir.get()) >> "%SCRIPT_NAME%"
echo         if dir: self.output_dir.set(dir) >> "%SCRIPT_NAME%"
echo     def log(self, message): >> "%SCRIPT_NAME%"
echo         self.log_text.config(state=tk.NORMAL) >> "%SCRIPT_NAME%"
echo         self.log_text.insert(tk.END, f"[{time.strftime('%%H:%%M:%%S')}] {message}\n") >> "%SCRIPT_NAME%"
echo         self.log_text.see(tk.END) >> "%SCRIPT_NAME%"
echo         self.log_text.config(state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo     def convert_all(self): >> "%SCRIPT_NAME%"
echo         input_path = self.input_dir.get() >> "%SCRIPT_NAME%"
echo         output_path = self.output_dir.get() >> "%SCRIPT_NAME%"
echo         if not os.path.exists(input_path): >> "%SCRIPT_NAME%"
echo             messagebox.showerror("Error", f"La carpeta de entrada no existe:\n{input_path}") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         os.makedirs(output_path, exist_ok=True) >> "%SCRIPT_NAME%"
echo         supported = ('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff') >> "%SCRIPT_NAME%"
echo         files = [f for f in os.listdir(input_path) if f.lower().endswith(supported)] >> "%SCRIPT_NAME%"
echo         if not files: >> "%SCRIPT_NAME%"
echo             self.log("No se encontraron imágenes en la carpeta de entrada.") >> "%SCRIPT_NAME%"
echo             messagebox.showinfo("Sin archivos", "No se encontraron imágenes compatibles en la carpeta seleccionada.") >> "%SCRIPT_NAME%"
echo             return >> "%SCRIPT_NAME%"
echo         self.convert_btn.config(state=tk.DISABLED) >> "%SCRIPT_NAME%"
echo         self.progress["maximum"] = len(files) >> "%SCRIPT_NAME%"
echo         self.progress["value"] = 0 >> "%SCRIPT_NAME%"
echo         quality = self.quality.get() >> "%SCRIPT_NAME%"
echo         out_fmt = self.output_format.get().lower() >> "%SCRIPT_NAME%"
echo         if out_fmt == 'jpg': out_fmt = 'jpeg' >> "%SCRIPT_NAME%"
echo         converted = 0 >> "%SCRIPT_NAME%"
echo         for i, filename in enumerate(files, 1): >> "%SCRIPT_NAME%"
echo             try: >> "%SCRIPT_NAME%"
echo                 full_input = os.path.join(input_path, filename) >> "%SCRIPT_NAME%"
echo                 ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'} >> "%SCRIPT_NAME%"
echo                 ext = ext_map.get(out_fmt, '.' + out_fmt) >> "%SCRIPT_NAME%"
echo                 out_filename = get_custom_filename(filename, ext) >> "%SCRIPT_NAME%"
echo                 full_output = os.path.join(output_path, out_filename) >> "%SCRIPT_NAME%"
echo                 self.log(f"Procesando ({i}/{len(files)}): {filename}") >> "%SCRIPT_NAME%"
echo                 self.root.update_idletasks() >> "%SCRIPT_NAME%"
echo                 with Image.open(full_input) as img: >> "%SCRIPT_NAME%"
echo                     if out_fmt == 'jpeg' and img.mode in ('RGBA', 'LA'): >> "%SCRIPT_NAME%"
echo                         bg = Image.new('RGB', img.size, (255, 255, 255)) >> "%SCRIPT_NAME%"
echo                         bg.paste(img, mask=img.split()[-1]) >> "%SCRIPT_NAME%"
echo                         img = bg >> "%SCRIPT_NAME%"
echo                     elif img.mode != 'RGB' and out_fmt == 'jpeg': >> "%SCRIPT_NAME%"
echo                         img = img.convert('RGB') >> "%SCRIPT_NAME%"
echo                     save_args = {'quality': quality} >> "%SCRIPT_NAME%"
echo                     if out_fmt == 'webp': save_args['method'] = 6 >> "%SCRIPT_NAME%"
echo                     elif out_fmt == 'png': >> "%SCRIPT_NAME%"
echo                         save_args.pop('quality', None) >> "%SCRIPT_NAME%"
echo                         save_args['optimize'] = True >> "%SCRIPT_NAME%"
echo                     img.save(full_output, format=out_fmt.upper(), **save_args) >> "%SCRIPT_NAME%"
echo                 converted += 1 >> "%SCRIPT_NAME%"
echo                 self.progress["value"] = i >> "%SCRIPT_NAME%"
echo             except Exception as e: >> "%SCRIPT_NAME%"
echo                 self.log(f"Error en {filename}: {str(e)}") >> "%SCRIPT_NAME%"
echo         self.log(f"Finalizado. Se convirtieron {converted} imágenes.") >> "%SCRIPT_NAME%"
echo         self.convert_btn.config(state=tk.NORMAL) >> "%SCRIPT_NAME%"
echo         if converted ^> 0: >> "%SCRIPT_NAME%"
echo             if messagebox.askyesno("Éxito", f"Se convirtieron {converted} imágenes.\n¿Abrir carpeta de salida?"): >> "%SCRIPT_NAME%"
echo                 os.startfile(output_path) >> "%SCRIPT_NAME%"
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
