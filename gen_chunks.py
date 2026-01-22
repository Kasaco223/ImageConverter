import base64

with open('icon_small_b64.txt', 'r') as f:
    b64 = f.read().strip()

chunk_size = 100
chunks = [b64[i:i+chunk_size] for i in range(0, len(b64), chunk_size)]

with open('chunks_echo.txt', 'w') as f:
    f.write('echo ICON_B64_CHUNKS = [ >> "%SCRIPT_NAME%"\n')
    for chunk in chunks:
        f.write(f'echo     "{chunk}", >> "%SCRIPT_NAME%"\n')
    f.write('echo ] >> "%SCRIPT_NAME%"\n')
    f.write('echo ICON_B64 = "".join(ICON_B64_CHUNKS) >> "%SCRIPT_NAME%"\n')

print(f"Generated {len(chunks)} echo commands.")
