import os
import math
import colorsys

REACT_SVG_DIR = r"C:\Users\odtgo\Documents\ProgramingLanguages\Proyectos\webMazahua\J-atrjo\client\src\assets\svgs\numbers"
os.makedirs(REACT_SVG_DIR, exist_ok=True)

def generate_svg(number_str, num_val):
    h1 = (num_val * 0.381966) % 1.0
    h2 = (h1 + 0.12) % 1.0
    h3 = (h1 + 0.25) % 1.0

    c1 = [int(c * 255) for c in colorsys.hsv_to_rgb(h1, 0.85, 1.0)]
    c2 = [int(c * 255) for c in colorsys.hsv_to_rgb(h2, 0.90, 0.92)]
    c3 = [int(c * 255) for c in colorsys.hsv_to_rgb(h3, 0.95, 0.70)]

    hex1 = f"#{c1[0]:02x}{c1[1]:02x}{c1[2]:02x}"
    hex2 = f"#{c2[0]:02x}{c2[1]:02x}{c2[2]:02x}"
    hex3 = f"#{c3[0]:02x}{c3[1]:02x}{c3[2]:02x}"

    font_size = 290 if len(number_str) == 1 else (220 if len(number_str) == 2 else 165)
    y_pos = 340 if len(number_str) == 1 else (325 if len(number_str) == 2 else 310)

    svg_content = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 500" width="100%" height="100%">
  <defs>
    <radialGradient id="grad-{num_val}" cx="35%" cy="30%" r="65%">
      <stop offset="0%" stop-color="{hex1}" />
      <stop offset="55%" stop-color="{hex2}" />
      <stop offset="100%" stop-color="{hex3}" />
    </radialGradient>
    <filter id="shadow-{num_val}" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="8" stdDeviation="6" flood-color="#0f0f23" flood-opacity="0.35"/>
    </filter>
  </defs>
  
  <g filter="url(#shadow-{num_val})">
    <!-- Sticker Outer White Border -->
    <text x="250" y="{y_pos}" 
          font-family="'Poppins', 'Montserrat', 'Arial Black', sans-serif" 
          font-weight="900" 
          font-size="{font_size}px" 
          fill="#ffffff" 
          stroke="#ffffff" 
          stroke-width="32" 
          stroke-linejoin="round" 
          stroke-linecap="round" 
          text-anchor="middle">{number_str}</text>
          
    <!-- Main Gradient Colored Number -->
    <text x="250" y="{y_pos}" 
          font-family="'Poppins', 'Montserrat', 'Arial Black', sans-serif" 
          font-weight="900" 
          font-size="{font_size}px" 
          fill="url(#grad-{num_val})" 
          text-anchor="middle">{number_str}</text>
  </g>
  
  <!-- Glossy Sheen Overlay -->
  <ellipse cx="250" cy="180" rx="180" ry="80" fill="#ffffff" opacity="0.18" clip-path="url(#clip-{num_val})"/>
  
  <!-- Sparkle Stars -->
  <g fill="#ffffff">
    <path d="M 90 120 Q 90 135 75 135 Q 90 135 90 150 Q 90 135 105 135 Q 90 135 90 120 Z" />
    <path d="M 400 140 Q 400 152 388 152 Q 400 152 400 164 Q 400 152 412 152 Q 400 152 400 140 Z" />
    <circle cx="80" cy="380" r="8" fill="{hex1}" opacity="0.85"/>
    <circle cx="420" cy="360" r="10" fill="{hex2}" opacity="0.85"/>
    <circle cx="430" cy="390" r="5" fill="#ffffff" opacity="0.9"/>
  </g>
</svg>'''

    file_path = os.path.join(REACT_SVG_DIR, f"number_{num_val}.svg")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(svg_content)
    return file_path

print("=== Generating 101 Vector SVG files for React frontend ===")
for i in range(101):
    generate_svg(str(i), i)
print("=== Complete! 101 SVGs generated in:", REACT_SVG_DIR)
