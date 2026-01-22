from PIL import Image
import base64
import io
import os

input_path = 'public/icon.PNG'
output_path = 'icon_small_b64.txt'

if os.path.exists(input_path):
    img = Image.open(input_path).convert("RGBA")
    # Resize to 64x64 for better quality while staying within limits
    img = img.resize((64, 64), Image.Resampling.LANCZOS)
    
    # Save as PNG to a buffer, ensuring transparency is kept
    buf = io.BytesIO()
    img.save(buf, format='PNG', optimize=True)
    
    # Encode to base64
    b64_data = base64.b64encode(buf.getvalue()).decode()
    
    with open(output_path, 'w') as f:
        f.write(b64_data)
    print(f"Base64 saved to {output_path}, size: {len(b64_data)}")
else:
    print(f"Error: {input_path} not found")
