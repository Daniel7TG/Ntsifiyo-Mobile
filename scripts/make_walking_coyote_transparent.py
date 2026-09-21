r"""
Process C:\Users\odtgo\Desktop\0730(2)_white_bg.mp4 to create assets\coyote\animations\walking.webp with transparent background.
Uses flood-fill starting from outer borders so internal white pixels (such as the eyes) stay 100% white/opaque.
"""
import os
import sys
import cv2
import numpy as np
from PIL import Image

VIDEO_PATH = r"C:\Users\odtgo\Desktop\0730(2)_white_bg.mp4"
OUTPUT_WEBP = os.path.join("assets", "coyote", "animations", "walking.webp")

if not os.path.exists(VIDEO_PATH):
    print(f"Error: Video file not found at {VIDEO_PATH}")
    sys.exit(1)

cap = cv2.VideoCapture(VIDEO_PATH)
fps = cap.get(cv2.CAP_PROP_FPS) or 30
frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
frame_duration = int(1000 / fps)

print(f"Processing video: {VIDEO_PATH}")
print(f"  FPS: {fps:.2f}, Frames: {frame_count}, Frame duration: {frame_duration}ms")

processed_frames = []
durations = []

frame_idx = 0
while True:
    ret, frame_bgr = cap.read()
    if not ret:
        break
    
    h, w, c = frame_bgr.shape
    
    # 1. Convert BGR to RGB
    frame_rgb = cv2.cvtColor(frame_bgr, cv2.COLOR_BGR2RGB)
    
    # 2. Identify near-white pixels (threshold RGB > 230)
    bg_mask = cv2.inRange(frame_rgb, (230, 230, 230), (255, 255, 255))
    
    # 3. Create a floodfill mask (h+2, w+2 for cv2.floodFill)
    ff_mask = np.zeros((h + 2, w + 2), dtype=np.uint8)
    
    # Invert bg_mask so non-bg pixels act as barriers (255 = barrier)
    ff_mask[1:h+1, 1:w+1] = np.where(bg_mask == 255, 0, 255).astype(np.uint8)
    
    # 4. Flood fill from outer border seeds
    seeds = []
    for x in range(0, w, 5):
        seeds.append((x, 0))
        seeds.append((x, h - 1))
    for y in range(0, h, 5):
        seeds.append((0, y))
        seeds.append((w - 1, y))
    
    outer_bg = np.zeros((h, w), dtype=np.uint8)
    
    for sx, sy in seeds:
        if ff_mask[sy + 1, sx + 1] == 0:
            cv2.floodFill(outer_bg, ff_mask, (sx, sy), 255)
            
    # 5. Create RGBA image
    rgba = np.dstack((frame_rgb, np.full((h, w), 255, dtype=np.uint8)))
    
    # 6. Feather boundary slightly
    blurred_mask = cv2.GaussianBlur(outer_bg, (3, 3), 0)
    
    # Alpha = 255 - blurred_mask
    alpha = np.clip(255 - blurred_mask, 0, 255).astype(np.uint8)
    
    rgba[:, :, 3] = alpha
    
    pil_frame = Image.fromarray(rgba, "RGBA")
    processed_frames.append(pil_frame)
    durations.append(frame_duration)
    
    frame_idx += 1
    if frame_idx % 10 == 0 or frame_idx == frame_count:
        print(f"  Processed frame {frame_idx}/{frame_count}")

cap.release()

print(f"Saving WebP animation to {OUTPUT_WEBP}...")
os.makedirs(os.path.dirname(OUTPUT_WEBP), exist_ok=True)

processed_frames[0].save(
    OUTPUT_WEBP,
    format="WEBP",
    save_all=True,
    append_images=processed_frames[1:],
    duration=durations,
    loop=0,
    lossless=True,
)

size_bytes = os.path.getsize(OUTPUT_WEBP)
print(f"Done! Saved {len(processed_frames)} frames to {OUTPUT_WEBP} ({size_bytes:,} bytes)")

sample = processed_frames[0]
arr = np.array(sample)
outer_pixel = arr[0, 0]
print(f"Outer corner pixel RGBA: {outer_pixel}")
