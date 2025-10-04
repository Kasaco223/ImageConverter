import os
import sys
from pathlib import Path
from PIL import Image
import warnings

# Suprimir advertencias de formatos no soportados
warnings.filterwarnings('ignore', category=UserWarning, module='PIL')

def convert_to_webp(input_path, output_path=None, quality=80):
    """
    Convert an image to WebP format (compatible con Windows).
    
    Args:
        input_path (str): Ruta al archivo de imagen de entrada (JPG/JPEG/PNG)
        output_path (str, optional): Ruta para guardar el archivo WebP de salida.
                                   Si no se proporciona, usará el nombre del archivo de entrada con extensión .webp
        quality (int): Calidad (1-100), mayor número significa mejor calidad pero archivo más grande
    """
    try:
        # Validate input file
        if not os.path.isfile(input_path):
            print(f"Error: Input file not found: {input_path}")
            return False
            
        # Verificar formato de archivo de entrada
        if not input_path.lower().endswith(('.jpg', '.jpeg', '.png')):
            print("Error: Solo archivos JPG/JPEG/PNG son soportados")
            return False
            
        # Establecer ruta de salida predeterminada si no se proporciona
        if output_path is None:
            output_path = os.path.splitext(input_path)[0] + '.webp'
            
        # Create output directory if it doesn't exist
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
            
        # Open and convert the image
        with Image.open(input_path) as img:
            # Convert to RGB if image has an alpha channel
            if img.mode in ('RGBA', 'LA'):
                background = Image.new('RGB', img.size, (255, 255, 255))
                background.paste(img, mask=img.split()[-1])
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
                
            # Guardar como WebP
            img.save(
                output_path,
                format='WEBP',
                quality=quality,
                method=6  # Método de compresión (0-6, 6 es el mejor pero más lento)
            )
            
            # Obtener tamaños de archivo para comparar
            original_size = os.path.getsize(input_path) / 1024  # KB
            new_size = os.path.getsize(output_path) / 1024  # KB
            reduction = ((original_size - new_size) / original_size) * 100
            
            print(f"Convertido: {os.path.basename(input_path)} -> {os.path.basename(output_path)}")
            print(f"   Tamaño original: {original_size:.1f} KB")
            print(f"   Nuevo tamaño: {new_size:.1f} KB")
            print(f"   Reducción: {reduction:.1f}%")
            
            return True
            
    except Exception as e:
        print(f"Error al convertir {os.path.basename(input_path)}: {str(e)}")
        return False

def batch_convert(input_dir, output_dir=None, recursive=False, **kwargs):
    """
    Convierte todos los archivos JPG/JPEG/PNG en un directorio a formato WebP.
    
    Args:
        input_dir (str): Directorio que contiene archivos JPG/JPEG/PNG
        output_dir (str, optional): Directorio para guardar los archivos convertidos.
                                   Si no se proporciona, los archivos se guardarán en el mismo directorio
        recursive (bool): Si es True, procesa los subdirectorios recursivamente
        **kwargs: Argumentos adicionales para pasar a convert_to_webp
    """
    if not os.path.isdir(input_dir):
        print(f"Error: Input directory not found: {input_dir}")
        return
        
    # Establecer directorio de salida
    if output_dir is None:
        output_dir = input_dir
    
    # Procesar archivos
    processed = 0
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith(('.jpg', '.jpeg', '.png')):
                input_path = os.path.join(root, file)
                
                # Create relative output path if recursive
                if recursive and output_dir != input_dir:
                    # Crear ruta de salida relativa si es recursivo
                    rel_path = os.path.relpath(root, input_dir)
                    current_output_dir = os.path.join(output_dir, rel_path)
                else:
                    current_output_dir = output_dir
                    
                # Create output filename
                output_filename = os.path.splitext(file)[0] + '.webp'
                output_path = os.path.join(current_output_dir, output_filename)
                
                # Convertir el archivo
                if convert_to_webp(input_path, output_path, **kwargs):
                    processed += 1
                    
        if not recursive:
            break
            
    print(f"\nConversion complete. Processed {processed} files.")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Convierte imágenes JPG/JPEG/PNG a formato WebP (compatible con Windows)')
    parser.add_argument('input', help='Archivo o directorio de entrada')
    parser.add_argument('-o', '--output', help='Archivo o directorio de salida')
    parser.add_argument('-q', '--quality', type=int, default=80, 
                       help='Calidad (1-100), mayor número significa mejor calidad (predeterminado: 80)')
    parser.add_argument('-r', '--recursive', action='store_true',
                       help='Procesar subdirectorios recursivamente')
    
    args = parser.parse_args()
    
    # Validar valor de calidad
    if not (1 <= args.quality <= 100):
        print("Error: La calidad debe estar entre 1 y 100")
        return 1
    
    # Check if input is file or directory
    if os.path.isfile(args.input):
        if args.output and os.path.isdir(args.output):
            # Si la salida es un directorio, crear la ruta completa
            filename = os.path.basename(args.input)
            output_path = os.path.join(args.output, os.path.splitext(filename)[0] + '.webp')
        else:
            output_path = args.output
            
        success = convert_to_webp(
            args.input, 
            output_path,
            quality=args.quality
        )
        return 0 if success else 1
        
    elif os.path.isdir(args.input):
        batch_convert(
            args.input,
            args.output,
            recursive=args.recursive,
            quality=args.quality
        )      
        return 0
    else:
        print(f"Error: Input not found: {args.input}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
