"""Optimize walking.webp file size while keeping high quality alpha channel."""
import os
from PIL import Image

path = "assets/coyote/animations/walking.webp"
im = Image.open(path)
frames = []
durations = []

for i in range(im.n_frames):
    im.seek(i)
    frames.append(im.convert("RGBA"))
    durations.append(im.info.get("duration", 41))

# Try saving with method=6 quality=90
temp_path = "assets/coyote/animations/walking_opt.webp"
frames[0].save(
    temp_path,
    format="WEBP",
    save_all=True,
    append_images=frames[1:],
    duration=durations,
    loop=0,
    quality=88,
    method=6,
)

orig_size = os.path.getsize(path)
opt_size = os.path.getsize(temp_path)
print(f"Original size:  {orig_size:,} bytes")
print(f"Optimized size: {opt_size:,} bytes ({opt_size * 100 // orig_size}%)")

if opt_size < orig_size:
    os.replace(temp_path, path)
    print("Replaced with optimized version!")
else:
    os.remove(temp_path)
