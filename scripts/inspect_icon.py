import os
from PIL import Image

path = r"C:\Users\odtgo\Desktop\3.png"
if os.path.exists(path):
    im = Image.open(path)
    print(f"Image found! Size: {im.size}, Mode: {im.mode}")
else:
    print(f"File NOT found at {path}")
