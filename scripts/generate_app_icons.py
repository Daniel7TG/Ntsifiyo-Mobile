r"""
Generate Android and app icons from C:\Users\odtgo\Desktop\3.png with 18% padding.
"""
import os
import shutil
from PIL import Image

SRC_PATH = r"C:\Users\odtgo\Desktop\3.png"
PROJ_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

ASSET_ICON = os.path.join(PROJ_ROOT, "assets", "app_icon.png")

if not os.path.exists(SRC_PATH):
    print(f"Error: Source image not found at {SRC_PATH}")
    exit(1)

src_img = Image.open(SRC_PATH).convert("RGBA")
print(f"Source image loaded: {src_img.size}")

shutil.copy(SRC_PATH, ASSET_ICON)

def create_padded_icon(img: Image.Image, size: int, padding_ratio: float = 0.18) -> Image.Image:
    """Create square canvas of `size` and place `img` inside with `padding_ratio` margin."""
    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    margin = int(size * padding_ratio)
    inner_size = size - 2 * margin
    resized_inner = img.resize((inner_size, inner_size), Image.Resampling.LANCZOS)
    canvas.paste(resized_inner, (margin, margin), resized_inner)
    return canvas

def create_resized_full(img: Image.Image, size: int) -> Image.Image:
    return img.resize((size, size), Image.Resampling.LANCZOS)

MIPMAP_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

DRAWABLE_SIZES = {
    "drawable-mdpi": 108,
    "drawable-hdpi": 162,
    "drawable-xhdpi": 216,
    "drawable-xxhdpi": 324,
    "drawable-xxxhdpi": 432,
}

RES_DIR = os.path.join(PROJ_ROOT, "android", "app", "src", "main", "res")

# 1. Generate ic_launcher.png with 18% padding for standard mipmaps
for folder, size in MIPMAP_SIZES.items():
    folder_path = os.path.join(RES_DIR, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    padded = create_padded_icon(src_img, size, 0.18)
    padded.save(os.path.join(folder_path, "ic_launcher.png"), "PNG")
    padded.save(os.path.join(folder_path, "ic_launcher_round.png"), "PNG")
    print(f"Generated {folder}: {size}x{size} px (18% padding)")

# 2. Generate ic_launcher_foreground.png
for folder, size in DRAWABLE_SIZES.items():
    folder_path = os.path.join(RES_DIR, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    full = create_resized_full(src_img, size)
    full.save(os.path.join(folder_path, "ic_launcher_foreground.png"), "PNG")
    print(f"Generated {folder} foreground: {size}x{size} px")

# 3. Update xml with 18% inset
ANYDPI_DIR = os.path.join(RES_DIR, "mipmap-anydpi-v26")
os.makedirs(ANYDPI_DIR, exist_ok=True)

XML_CONTENT = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground>
      <inset
          android:drawable="@drawable/ic_launcher_foreground"
          android:inset="18%" />
  </foreground>
</adaptive-icon>
"""

with open(os.path.join(ANYDPI_DIR, "ic_launcher.xml"), "w", encoding="utf-8") as f:
    f.write(XML_CONTENT)

with open(os.path.join(ANYDPI_DIR, "ic_launcher_round.xml"), "w", encoding="utf-8") as f:
    f.write(XML_CONTENT)

print("Updated ic_launcher.xml and ic_launcher_round.xml to 18% inset padding.")

WEB_DIR = os.path.join(PROJ_ROOT, "web")
if os.path.exists(WEB_DIR):
    create_padded_icon(src_img, 192, 0.18).save(os.path.join(WEB_DIR, "icons", "Icon-192.png"), "PNG")
    create_padded_icon(src_img, 512, 0.18).save(os.path.join(WEB_DIR, "icons", "Icon-512.png"), "PNG")
    create_padded_icon(src_img, 64, 0.18).save(os.path.join(WEB_DIR, "favicon.png"), "PNG")
    print("Updated Web icons.")

print("All icons generated with 18% padding successfully!")
