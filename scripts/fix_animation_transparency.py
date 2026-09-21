"""
Remove black/white backgrounds from animated WebP files and re-save with transparency.
Uses chroma-key approach: pixels close to the background color become transparent.
"""
import os
import sys
from PIL import Image
import numpy as np

ANIM_DIR = os.path.join("assets", "coyote", "animations")

# Tolerance for background removal (0-255).
# Pixels within this distance from the bg color become transparent.
TOLERANCE = 30

def remove_background(frame_rgba: Image.Image, bg_color: tuple) -> Image.Image:
    """Remove background color from a single RGBA frame."""
    arr = np.array(frame_rgba, dtype=np.float32)
    
    bg = np.array(bg_color[:3], dtype=np.float32)
    
    # Calculate distance from background color
    diff = np.sqrt(np.sum((arr[:, :, :3] - bg) ** 2, axis=2))
    
    # Create alpha mask: 0 where close to bg, 255 where far
    # Use a smooth transition zone for anti-aliasing
    alpha = np.clip((diff - TOLERANCE * 0.5) / (TOLERANCE * 0.5) * 255, 0, 255).astype(np.uint8)
    
    # Set the alpha channel
    result = arr.copy().astype(np.uint8)
    result[:, :, 3] = alpha
    
    return Image.fromarray(result, "RGBA")

def process_animated_webp(filepath: str):
    """Process an animated WebP: remove bg from all frames, re-save."""
    print(f"\nProcessing: {filepath}")
    im = Image.open(filepath)
    
    n_frames = getattr(im, "n_frames", 1)
    if n_frames <= 1:
        print(f"  Skipping (not animated, {n_frames} frames)")
        return
    
    # Detect background from first frame corners
    im.seek(0)
    first = im.convert("RGBA")
    corners = [first.getpixel((x, y))[:3] for x, y in [
        (0, 0), (first.size[0]-1, 0), (0, first.size[1]-1), (first.size[0]-1, first.size[1]-1)
    ]]
    # Use the most common corner color as bg
    bg_color = max(set(corners), key=corners.count)
    print(f"  Detected bg: RGB{bg_color}, frames: {n_frames}")
    
    frames = []
    durations = []
    
    for i in range(n_frames):
        im.seek(i)
        frame = im.convert("RGBA")
        duration = im.info.get("duration", 50)
        
        cleaned = remove_background(frame, bg_color)
        frames.append(cleaned)
        durations.append(duration)
        
        if (i + 1) % 20 == 0:
            print(f"  Frame {i+1}/{n_frames} done")
    
    print(f"  All {n_frames} frames processed. Saving...")
    
    # Save as animated WebP with transparency
    # Backup the original
    backup = filepath + ".bak"
    if not os.path.exists(backup):
        os.rename(filepath, backup)
    else:
        os.remove(filepath)
    
    frames[0].save(
        filepath,
        format="WEBP",
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        lossless=True,  # lossless to preserve alpha quality
    )
    
    old_size = os.path.getsize(backup)
    new_size = os.path.getsize(filepath)
    print(f"  Saved: {old_size:,} -> {new_size:,} bytes")
    
    # Verify
    verify = Image.open(filepath)
    verify.seek(0)
    vf = verify.convert("RGBA")
    tp = sum(1 for p in vf.getdata() if p[3] < 128)
    total = vf.size[0] * vf.size[1]
    print(f"  Verification: {tp}/{total} transparent pixels ({tp*100//total}%)")

def main():
    webp_files = [f for f in os.listdir(ANIM_DIR) if f.endswith(".webp")]
    print(f"Found {len(webp_files)} animated WebP files in {ANIM_DIR}")
    
    for f in sorted(webp_files):
        process_animated_webp(os.path.join(ANIM_DIR, f))
    
    print("\n=== Done! ===")

if __name__ == "__main__":
    main()
