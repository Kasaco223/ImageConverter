import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from PIL import Image, ImageTk
import os
import shutil
import sys
from pathlib import Path

class ImageConverterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Conversor de Imágenes")
        self.root.geometry("800x600")
        self.root.minsize(700, 500)
        
        # Variables
        self.quality = tk.IntVar(value=80)
        self.output_format = tk.StringVar(value="webp")
        self.files_to_convert = []
        self.output_dir = os.path.join(os.path.expanduser("~"), "Imágenes Comprimidas")
        
        # Crear directorio de salida si no existe
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Estilo
        self.style = ttk.Style()
        self.style.configure('TFrame', background='#f0f0f0')
        self.style.configure('TLabel', background='#f0f0f0')
        self.style.configure('TButton', padding=5)
        
        # Frame principal
        self.main_frame = ttk.Frame(root, padding="10")
        self.main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Panel de arrastrar y soltar
        self.drop_frame = ttk.LabelFrame(self.main_frame, text="Arrastra imágenes aquí", padding="20")
        self.drop_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        self.drop_label = ttk.Label(
            self.drop_frame, 
            text="Arrastra y suelta imágenes aquí\no haz clic para seleccionar",
            justify=tk.CENTER
        )
        self.drop_label.pack(expand=True)
        
        # Controles
        self.controls_frame = ttk.Frame(self.main_frame)
        self.controls_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Calidad
        ttk.Label(self.controls_frame, text="Calidad:").pack(side=tk.LEFT, padx=(0, 5))
        self.quality_scale = ttk.Scale(
            self.controls_frame, 
            from_=1, 
            to=100, 
            orient=tk.HORIZONTAL,
            variable=self.quality,
            command=lambda v: self.quality_var.set(f"{int(float(v))}%")
        )
        self.quality_scale.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 10))
        
        self.quality_var = tk.StringVar(value=f"{self.quality.get()}%")
        ttk.Label(self.controls_frame, textvariable=self.quality_var, width=5).pack(side=tk.LEFT)
        
        # Formato de salida
        ttk.Label(self.controls_frame, text="Formato:").pack(side=tk.LEFT, padx=(10, 5))
        self.format_menu = ttk.Combobox(
            self.controls_frame, 
            textvariable=self.output_format,
            values=["webp", "jpg", "png"],
            state="readonly",
            width=8
        )
        self.format_menu.pack(side=tk.LEFT, padx=(0, 10))
        
        # Botón de conversión
        self.convert_btn = ttk.Button(
            self.controls_frame, 
            text="Convertir", 
            command=self.convert_images,
            style="Accent.TButton"
        )
        self.convert_btn.pack(side=tk.RIGHT)
        
        # Barra de progreso
        self.progress = ttk.Progressbar(
            self.main_frame, 
            orient=tk.HORIZONTAL, 
            length=100, 
            mode='determinate'
        )
        self.progress.pack(fill=tk.X, pady=(0, 10))
        
        # Log
        self.log_frame = ttk.LabelFrame(self.main_frame, text="Registro", padding="5")
        self.log_frame.pack(fill=tk.BOTH, expand=True)
        
        self.log_text = tk.Text(
            self.log_frame, 
            height=10, 
            wrap=tk.WORD,
            state=tk.DISABLED
        )
        self.log_text.pack(fill=tk.BOTH, expand=True)
        
        # Configurar eventos de arrastrar y soltar
        self.drop_frame.drop_target_register('DND_Files')
        self.drop_frame.dnd_bind('<<Drop>>', self.on_drop)
        
        # Configurar evento de clic
        self.drop_frame.bind("<Button-1>", self.on_click)
        
        # Configurar estilo del botón de conversión
        self.style.configure('Accent.TButton', background='#4CAF50', foreground='white')
        
        self.log("Listo para convertir imágenes. Arrastra y suelta archivos o haz clic para seleccionar.")
    
    def log(self, message):
        self.log_text.config(state=tk.NORMAL)
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        self.log_text.config(state=tk.DISABLED)
    
    def on_drop(self, event):
        # Obtener la lista de archivos
        files = self.root.tk.splitlist(event.data)
        self.process_files(files)
    
    def on_click(self, event):
        # Abrir diálogo para seleccionar archivos
        files = filedialog.askopenfilenames(
            title="Seleccionar imágenes",
            filetypes=(
                ("Imágenes", "*.jpg *.jpeg *.png"),
                ("Todos los archivos", "*.*")
            )
        )
        if files:
            self.process_files(files)
    
    def process_files(self, files):
        supported_formats = ('.jpg', '.jpeg', '.png', '.webp')
        new_files = []
        
        for file_path in files:
            # Verificar si el archivo es una imagen soportada
            ext = os.path.splitext(file_path)[1].lower()
            if ext in supported_formats:
                new_files.append(file_path)
        
        if not new_files:
            messagebox.showwarning("Sin archivos válidos", "No se encontraron archivos de imagen válidos.")
            return
        
        self.files_to_convert = list(set(self.files_to_convert + new_files))
        self.update_drop_label()
    
    def update_drop_label(self):
        if not self.files_to_convert:
            self.drop_label.config(text="Arrastra imágenes aquí\no haz clic para seleccionar")
            return
        
        file_count = len(self.files_to_convert)
        if file_count == 1:
            filename = os.path.basename(self.files_to_convert[0])
            if len(filename) > 30:
                filename = filename[:15] + "..." + filename[-15:]
            self.drop_label.config(text=f"1 archivo listo para convertir:\n{filename}")
        else:
            self.drop_label.config(text=f"{file_count} archivos listos para convertir")
    
    def convert_images(self):
        if not self.files_to_convert:
            messagebox.showinfo("Sin archivos", "No hay archivos para convertir.")
            return
        
        output_format = self.output_format.get().lower()
        quality = self.quality.get()
        total_files = len(self.files_to_convert)
        converted_count = 0
        
        # Crear directorio de salida si no existe
        output_dir = os.path.join(self.output_dir, f"converted_{int(time.time())}")
        os.makedirs(output_dir, exist_ok=True)
        
        self.convert_btn.config(state=tk.DISABLED)
        self.progress["maximum"] = total_files
        self.progress["value"] = 0
        
        for i, input_path in enumerate(self.files_to_convert, 1):
            try:
                filename = os.path.basename(input_path)
                name_without_ext = os.path.splitext(filename)[0]
                output_path = os.path.join(output_dir, f"{name_without_ext}.{output_format}")
                
                # Actualizar interfaz
                self.log(f"Convirtiendo {i}/{total_files}: {filename}")
                self.progress["value"] = i
                self.root.update_idletasks()
                
                # Convertir imagen
                with Image.open(input_path) as img:
                    # Convertir a RGB si es necesario
                    if img.mode in ('RGBA', 'LA'):
                        background = Image.new('RGB', img.size, (255, 255, 255))
                        background.paste(img, mask=img.split()[-1])
                        img = background
                    elif img.mode != 'RGB':
                        img = img.convert('RGB')
                    
                    # Guardar en el formato de salida
                    img.save(
                        output_path,
                        format=output_format.upper(),
                        quality=quality,
                        optimize=True
                    )
                
                converted_count += 1
                
            except Exception as e:
                self.log(f"Error al convertir {os.path.basename(input_path)}: {str(e)}")
        
        # Mostrar resumen
        self.log(f"\nConversión completada: {converted_count} de {total_files} archivos convertidos.")
        self.log(f"Los archivos se guardaron en: {output_dir}")
        
        # Reiniciar estado
        self.files_to_convert = []
        self.update_drop_label()
        self.convert_btn.config(state=tk.NORMAL)
        
        # Abrir carpeta de destino
        if converted_count > 0:
            if messagebox.askyesno("Conversión completada", 
                                 f"Se convirtieron {converted_count} archivos.\n¿Deseas abrir la carpeta de destino?"):
                os.startfile(output_dir)

def main():
    root = tk.Tk()
    app = ImageConverterApp(root)
    root.mainloop()

if __name__ == "__main__":
    import time
    main()
