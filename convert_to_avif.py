import os
import sys
from pathlib import Path
from PIL import Image
import warnings
from datetime import datetime, timedelta, timezone

# Suprimir advertencias de formatos no soportados
warnings.filterwarnings('ignore', category=UserWarning, module='PIL')

def get_colombia_timestamp():
    """Returns current timestamp in Colombia time (UTC-5) format HHMMDDMMYYYY"""
    # Get current time in UTC
    now_utc = datetime.now(timezone.utc)
    # Convert to Colombia time (UTC-5)
    colombia_offset = timezone(timedelta(hours=-5))
    now_colombia = now_utc.astimezone(colombia_offset)
    # Format: HHMMDDMMYYYY
    return now_colombia.strftime("%H%M%d%m%Y")

def get_custom_filename(original_filename, ext):
    """Generates filename with format: original_K_HHMMDDMMYYYY.ext"""
    name_without_ext = os.path.splitext(original_filename)[0]
    timestamp = get_colombia_timestamp()
    return f"{name_without_ext}_K_{timestamp}{ext}"

def convert_image(input_path, output_path=None, quality=80, output_format='webp'):
    """
    Convert an image to specified format.
    
    Args:
        input_path (str): Ruta al archivo de imagen de entrada
        output_path (str, optional): Ruta para guardar el archivo de salida.
        quality (int): Calidad (1-100)
        output_format (str): Formato de salida ('webp', 'jpeg', 'png')
    """
    try:
        # Validate input file
        if not os.path.isfile(input_path):
            print(f"Error: Input file not found: {input_path}")
            return False
            
        # Verificar formato de archivo de entrada
        if not input_path.lower().endswith(('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff')):
            # Intentar abrirlo de todos modos, PIL maneja muchos formatos
            pass
            
        # Normalizar formato
        output_format = output_format.lower()
        if output_format == 'jpg':
            output_format = 'jpeg'
            
        # Establecer extensión correcta
        ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'}
        ext = ext_map.get(output_format, '.' + output_format)
            
        # Establecer ruta de salida predeterminada si no se proporciona
        if output_path is None:
            # Use custom naming convention
            filename = os.path.basename(input_path)
            output_path = get_custom_filename(filename, ext)
            
        # Create output directory if it doesn't exist
        output_dir = os.path.dirname(output_path)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)
            
        # Open and convert the image
        with Image.open(input_path) as img:
            # Convert to RGB if saving as JPEG (doesn't support alpha)
            if output_format == 'jpeg' and img.mode in ('RGBA', 'LA'):
                background = Image.new('RGB', img.size, (255, 255, 255))
                background.paste(img, mask=img.split()[-1])
                img = background
            elif img.mode in ('RGBA', 'LA') and output_format == 'webp':
                # WebP supports transparency, but let's ensure it's handled correctly
                pass
            elif img.mode != 'RGB' and output_format == 'jpeg':
                img = img.convert('RGB')
                
            # Guardar imagen
            save_args = {'quality': quality}
            
            if output_format == 'webp':
                save_args['method'] = 6
            elif output_format == 'png':
                # PNG es lossless, quality se usa para compress_level (0-9)
                # Mapeamos 0-100 a 0-9 aprox
                save_args.pop('quality', None)
                save_args['optimize'] = True
            
            img.save(output_path, format=output_format.upper(), **save_args)
            
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

def batch_convert(input_dir, output_dir=None, recursive=False, output_format='webp', **kwargs):
    """
    Convierte todos los archivos de imagen en un directorio.
    """
    if not os.path.isdir(input_dir):
        print(f"Error: Input directory not found: {input_dir}")
        return
        
    # Establecer directorio de salida
    if output_dir is None:
        output_dir = input_dir
    
    # Procesar archivos
    processed = 0
    supported_exts = ('.jpg', '.jpeg', '.png', '.webp', '.bmp', '.tiff')
    
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file.lower().endswith(supported_exts):
                input_path = os.path.join(root, file)
                
                # Create relative output path if recursive
                if recursive and output_dir != input_dir:
                    rel_path = os.path.relpath(root, input_dir)
                    current_output_dir = os.path.join(output_dir, rel_path)
                else:
                    current_output_dir = output_dir
                    
                # Determinar extensión de salida
                fmt = output_format.lower()
                if fmt == 'jpg': fmt = 'jpeg'
                ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'}
                ext = ext_map.get(fmt, '.' + fmt)
                
                # Create output filename with custom convention
                output_filename = get_custom_filename(file, ext)
                output_path = os.path.join(current_output_dir, output_filename)
                
                # Convertir el archivo
                if convert_image(input_path, output_path, output_format=output_format, **kwargs):
                    processed += 1
                    
        if not recursive:
            break
            
    print(f"\nConversion complete. Processed {processed} files.")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Convierte imágenes a formato WebP, JPG o PNG')
    parser.add_argument('input', help='Archivo o directorio de entrada')
    parser.add_argument('-o', '--output', help='Archivo o directorio de salida')
    parser.add_argument('-q', '--quality', type=int, default=80, 
                       help='Calidad (1-100) (predeterminado: 80)')
    parser.add_argument('-r', '--recursive', action='store_true',
                       help='Procesar subdirectorios recursivamente')
    parser.add_argument('-f', '--format', default='webp', choices=['webp', 'jpg', 'jpeg', 'png'],
                       help='Formato de salida (predeterminado: webp)')
    
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
            fmt = args.format.lower()
            if fmt == 'jpg': fmt = 'jpeg'
            ext_map = {'jpeg': '.jpg', 'webp': '.webp', 'png': '.png'}
            ext = ext_map.get(fmt, '.' + fmt)
            
            # Use custom naming convention
            output_filename = get_custom_filename(filename, ext)
            output_path = os.path.join(args.output, output_filename)
        else:
            output_path = args.output
            
        success = convert_image(
            args.input, 
            output_path,
            quality=args.quality,
            output_format=args.format
        )
        return 0 if success else 1
        
    elif os.path.isdir(args.input):
        batch_convert(
            args.input,
            args.output,
            recursive=args.recursive,
            quality=args.quality,
            output_format=args.format
        )      
        return 0
    else:
        print(f"Error: Input not found: {args.input}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
