from PIL import Image
import base64
import io
import os

input_path = 'public/icon.PNG'
output_path = 'icon_b64.txt'

if os.path.exists(input_path):
    img = Image.open(input_path)
    # Resize to a reasonable icon size (256x256 is max for Windows icons)
    img.thumbnail((256, 256))
    
    # Save as PNG to a buffer
    buf = io.BytesIO()
    img.save(buf, format='PNG')
    
    # Encode to base64
    b64_data = base64.b64encode(buf.getvalue()).decode()
    
    with open(output_path, 'w') as f:
        f.write(b64_data)
    print(f"Base64 saved to {output_path}")
else:
    print(f"Error: {input_path} not found")
