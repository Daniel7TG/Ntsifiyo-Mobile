"""Verify transparency of walking.webp: outer background is alpha 0, eyes/white inside are alpha 255."""
from PIL import Image
import numpy as np

path = "assets/coyote/animations/walking.webp"
im = Image.open(path)
print(f"Total frames: {im.n_frames}")

im.seek(0)
frame = im.convert("RGBA")
arr = np.array(frame)

# 1. Corner pixels (should be 0 alpha)
corners = [arr[0, 0], arr[0, -1], arr[-1, 0], arr[-1, -1]]
print("Corner pixels RGBA:")
for c in corners:
    print(" ", c)

# 2. Total transparent vs opaque pixels
transparent_count = np.sum(arr[:, :, 3] < 128)
opaque_count = np.sum(arr[:, :, 3] >= 128)
total = arr.shape[0] * arr.shape[1]

print(f"\nFrame 0 stats ({arr.shape[1]}x{arr.shape[0]}):")
print(f"  Transparent pixels: {transparent_count} ({transparent_count * 100 // total}%)")
print(f"  Opaque pixels:      {opaque_count} ({opaque_count * 100 // total}%)")

# 3. Find pure white pixels [255, 255, 255] in frame
white_pixels_mask = (arr[:, :, 0] == 255) & (arr[:, :, 1] == 255) & (arr[:, :, 2] == 255)
opaque_white_count = np.sum(white_pixels_mask & (arr[:, :, 3] == 255))
transparent_white_count = np.sum(white_pixels_mask & (arr[:, :, 3] == 0))

print(f"\nPure white [255, 255, 255] pixels breakdown:")
print(f"  Opaque white (eyes/teeth/body): {opaque_white_count}")
print(f"  Transparent white (outer bg):   {transparent_white_count}")
