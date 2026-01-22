import tkinter as tk 
from tkinter import ttk, filedialog, messagebox 
from PIL import Image, ImageTk 
import os 
import shutil 
import sys 
from pathlib import Path 
from datetime import datetime, timedelta, timezone 
import time 
import base64 
import tempfile 
 
ICON_B64_CHUNKS = [ 
    "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", 
] 
ICON_B64 = "".join(ICON_B64_CHUNKS) 
 
def set_icon(root): 
    try: 
        with tempfile.NamedTemporaryFile(delete=False, suffix='.png') as tmp: 
            tmp.write(base64.b64decode(ICON_B64)) 
            tmp_path = tmp.name 
        img = tk.PhotoImage(file=tmp_path) 
        root.iconphoto(True, img) 
        os.remove(tmp_path) 
    except: 
        pass 
 
def get_colombia_timestamp(): 
    now_utc = datetime.now(timezone.utc) 
    colombia_offset = timezone(timedelta(hours=-5)) 
    now_colombia = now_utc.astimezone(colombia_offset) 
    return now_colombia.strftime("%H%M%d%m%Y") 
 
def get_custom_filename(original_filename, ext): 
    name_without_ext = os.path.splitext(original_filename)[0] 
    timestamp = get_colombia_timestamp() 
    return f"{name_without_ext}_K_{timestamp}{ext}" 
 
class ImageConverterApp: 
    def __init__(self, root): 
        self.root = root 
        self.root.title("Conversor de Imágenes - Modo Oscuro") 
        self.root.geometry("800x650") 
        self.root.configure(bg='#1e1e1e') 
        self.input_dir = tk.StringVar(value=os.path.join(os.getcwd(), "input")) 
        self.output_dir = tk.StringVar(value=os.path.join(os.getcwd(), "output")) 
        self.quality = tk.IntVar(value=80) 
        self.output_format = tk.StringVar(value="webp") 
        self.setup_styles() 
        set_icon(self.root) 
        self.create_widgets() 
    def setup_styles(self): 
        style = ttk.Style() 
        style.theme_use('clam') 
        bg_color = '#1e1e1e' 
        fg_color = '#ffffff' 
        accent_color = '#4CAF50' 
        style.configure('TFrame', background=bg_color) 
        style.configure('TLabel', background=bg_color, foreground=fg_color, font=('Segoe UI', 10)) 
        style.configure('TLabelframe', background=bg_color, foreground=fg_color) 
        style.configure('TLabelframe.Label', background=bg_color, foreground=fg_color, font=('Segoe UI', 10, 'bold')) 
        style.configure('TButton', padding=5, font=('Segoe UI', 10)) 
        style.map('TButton', background=[('active', '#3d3d3d')], foreground=[('active', '#ffffff')]) 
        style.configure('Accent.TButton', background=accent_color, foreground='white') 
        style.map('Accent.TButton', background=[('active', '#45a049')]) 
        style.configure('TEntry', fieldbackground='#3d3d3d', foreground='white', insertcolor='white') 
        style.configure('TCombobox', fieldbackground='#3d3d3d', foreground='white', background='#3d3d3d') 
    def create_widgets(self): 
        main_frame = ttk.Frame(self.root, padding="20") 
        main_frame.pack(fill=tk.BOTH, expand=True) 
        folder_frame = ttk.LabelFrame(main_frame, text=" Carpetas ", padding="15") 
        folder_frame.pack(fill=tk.X, pady=(0, 20)) 
        ttk.Label(folder_frame, text="Carpeta de Entrada:").grid(row=0, column=0, sticky=tk.W, pady=5) 
        ttk.Entry(folder_frame, textvariable=self.input_dir, width=60).grid(row=0, column=1, padx=10, pady=5) 
        ttk.Button(folder_frame, text="Buscar", command=self.browse_input).grid(row=0, column=2, pady=5) 
        ttk.Label(folder_frame, text="Carpeta de Salida:").grid(row=1, column=0, sticky=tk.W, pady=5) 
        ttk.Entry(folder_frame, textvariable=self.output_dir, width=60).grid(row=1, column=1, padx=10, pady=5) 
        ttk.Button(folder_frame, text="Buscar", command=self.browse_output).grid(row=1, column=2, pady=5) 
        controls_frame = ttk.LabelFrame(main_frame, text=" Ajustes de Conversión ", padding="15") 
        controls_frame.pack(fill=tk.X, pady=(0, 20)) 
        ttk.Label(controls_frame, text="Calidad:").pack(side=tk.LEFT, padx=(0, 10)) 
        self.quality_scale = ttk.Scale(controls_frame, from_=1, to=100, orient=tk.HORIZONTAL, variable=self.quality, command=self.update_quality_label) 
        self.quality_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10)) 
        self.quality_label = ttk.Label(controls_frame, text=f"{self.quality.get()}%", width=5) 
        self.quality_label.pack(side=tk.LEFT) 
        ttk.Label(controls_frame, text="Formato:").pack(side=tk.LEFT, padx=(20, 10)) 
        self.format_menu = ttk.Combobox(controls_frame, textvariable=self.output_format, values=["webp", "jpg", "png"], state="readonly", width=10) 
        self.format_menu.pack(side=tk.LEFT) 
        self.convert_btn = ttk.Button(main_frame, text="CONVERTIR TODO", command=self.convert_all, style="Accent.TButton") 
        self.convert_btn.pack(fill=tk.X, pady=(0, 20)) 
        self.progress = ttk.Progressbar(main_frame, orient=tk.HORIZONTAL, length=100, mode='determinate') 
        self.progress.pack(fill=tk.X, pady=(0, 10)) 
        log_frame = ttk.LabelFrame(main_frame, text=" Registro de Actividad ", padding="5") 
        log_frame.pack(fill=tk.BOTH, expand=True) 
        self.log_text = tk.Text(log_frame, height=12, bg='#121212', fg='#00ff00', font=('Consolas', 10), borderwidth=0) 
        self.log_text.pack(fill=tk.BOTH, expand=True) 
        self.log("Listo. El programa buscará imágenes en la carpeta 'input' por defecto.") 
    def update_quality_label(self, event): 
        self.quality_label.config(text=f"{int(float(self.quality.get()))}%") 
    def browse_input(self): 
        dir = filedialog.askdirectory(initialdir=self.input_dir.get()) 
        if dir: self.input_dir.set(dir) 
    def browse_output(self): 
        dir = filedialog.askdirectory(initialdir=self.output_dir.get()) 
        if dir: self.output_dir.set(dir) 
    def log(self, message): 
        self.log_text.config(state=tk.NORMAL) 
        self.log_text.insert(tk.END, f"[{time.strftime('%H:%M:%S')}] {message}\n") 
        self.log_text.see(tk.END) 
        self.log_text.config(state=tk.DISABLED) 
    def convert_all(self): 
        input_path = self.input_dir.get() 
        output_path = self.output_dir.get() 
        if not os.path.exists(input_path): 
            messagebox.showerror("Error", f"La carpeta de entrada no existe:\n{input_path}") 
            return 
        os.makedirs(output_path, exist_ok=True) 
        supported = ('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff') 
        files = [f for f in os.listdir(input_path) if f.lower().endswith(supported)] 
        if not files: 
            self.log("No se encontraron imágenes en la carpeta de entrada.") 
            messagebox.showinfo("Sin archivos", "No se encontraron imágenes compatibles en la carpeta seleccionada.") 
            return 
        self.convert_btn.config(state=tk.DISABLED) 
        self.progress["maximum"] = len(files) 
        self.progress["value"] = 0 
        quality = self.quality.get() 
        out_fmt = self.output_format.get().lower() 
        if out_fmt == 'jpg': out_fmt = 'jpeg' 
        converted = 0 
        for i, filename in enumerate(files, 1): 
            try: 
                full_input = os.path.join(input_path, filename) 
                ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'} 
                ext = ext_map.get(out_fmt, '.' + out_fmt) 
                out_filename = get_custom_filename(filename, ext) 
                full_output = os.path.join(output_path, out_filename) 
                self.log(f"Procesando ({i}/{len(files)}): {filename}") 
                self.root.update_idletasks() 
                with Image.open(full_input) as img: 
                    if out_fmt == 'jpeg' and img.mode in ('RGBA', 'LA'): 
                        bg = Image.new('RGB', img.size, (255, 255, 255)) 
                        bg.paste(img, mask=img.split()[-1]) 
                        img = bg 
                    elif img.mode != 'RGB' and out_fmt == 'jpeg': 
                        img = img.convert('RGB') 
                    save_args = {'quality': quality} 
                    if out_fmt == 'webp': save_args['method'] = 6 
                    elif out_fmt == 'png': 
                        save_args.pop('quality', None) 
                        save_args['optimize'] = True 
                    img.save(full_output, format=out_fmt.upper(), **save_args) 
                converted += 1 
                self.progress["value"] = i 
            except Exception as e: 
                self.log(f"Error en {filename}: {str(e)}") 
        self.log(f"Finalizado. Se convirtieron {converted} imágenes.") 
        self.convert_btn.config(state=tk.NORMAL) 
        if converted > 0: 
            if messagebox.askyesno("Éxito", f"Se convirtieron {converted} imágenes.\n¿Abrir carpeta de salida?"): 
                os.startfile(output_path) 
def main(): 
    root = tk.Tk() 
    app = ImageConverterApp(root) 
    root.mainloop() 
if __name__ == "__main__": 
    main() 
