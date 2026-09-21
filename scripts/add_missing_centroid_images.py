import os
import json
from PIL import Image

artifact_dir = r"C:\Users\odtgo\.gemini\antigravity-cli\brain\7e6f7e45-12c1-4a1a-b19a-d1a88b07de8c"
out_img_dir = r"assets\dictionary\img"
manifest_path = r"assets\dictionary\manifest.json"

mappings = [
    {'key': 'agua', 'jpg': 'agua_sticker_1786262067735.jpg', 'id': 301, 'sp': 'agua', 'mz': 'dehe', 'cat': 'FOOD'},
    {'key': 'arroz', 'jpg': 'arroz_sticker_1786262081655.jpg', 'id': 302, 'sp': 'arroz', 'mz': 'aro', 'cat': 'FOOD'},
    {'key': 'huevo', 'jpg': 'huevo_sticker_1786262092534.jpg', 'id': 303, 'sp': 'huevo', 'mz': 'cjuano', 'cat': 'FOOD'},
    {'key': 'laMano', 'jpg': 'lamano_sticker_1786262103343.jpg', 'id': 304, 'sp': 'la mano', 'mz': 'nu dyëë', 'cat': 'BODY_PARTS'},
    {'key': 'mole', 'jpg': 'mole_sticker_1786262114636.jpg', 'id': 305, 'sp': 'mole', 'mz': 'mole', 'cat': 'FOOD'},
    {'key': 'pollito', 'jpg': 'pollito_sticker_1786262174846.jpg', 'id': 306, 'sp': 'pollito', 'mz': 'chïchï', 'cat': 'ANIMALS'},
    {'key': 'queso', 'jpg': 'queso_sticker_1786262185445.jpg', 'id': 307, 'sp': 'queso', 'mz': 'queso', 'cat': 'FOOD'},
    {'key': 'salsa', 'jpg': 'salsa_sticker_1786262316082.jpg', 'id': 308, 'sp': 'salsa', 'mz': "t'ösä", 'cat': 'FOOD'},
    {'key': 'zapato', 'jpg': 'zapato_sticker_1786262287910.jpg', 'id': 309, 'sp': 'zapato', 'mz': 'zapatu', 'cat': 'CLOTHES'},
    {'key': 'zapato-huarache', 'jpg': 'huarache_sticker_1786262298940.jpg', 'id': 310, 'sp': 'zapato huarache', 'mz': 'jñiji', 'cat': 'CLOTHES'}
]

print("1. Converting JPG images to 500x500 WEBP in assets/dictionary/img...")
os.makedirs(out_img_dir, exist_ok=True)
for item in mappings:
    jpg_path = os.path.join(artifact_dir, item['jpg'])
    webp_filename = f"{item['id']}.webp"
    webp_path = os.path.join(out_img_dir, webp_filename)
    
    im = Image.open(jpg_path).convert('RGB')
    im.thumbnail((500, 500), Image.LANCZOS)
    im.save(webp_path, 'WEBP', quality=80)
    print(f"   Saved {webp_filename} ({os.path.getsize(webp_path)} bytes)")

print("\n2. Updating manifest.json...")
with open(manifest_path, 'r', encoding='utf-8') as f:
    manifest = json.load(f)

existing_ids = set(w['id'] for w in manifest['words'])

added_count = 0
for item in mappings:
    if item['id'] not in existing_ids:
        entry = {
            'id': item['id'],
            'spanishWord': item['sp'],
            'mazahuaWord': item['mz'],
            'spanishPronunciation': None,
            'mazahuaPronunciation': None,
            'category': item['cat'],
            'image': f"img/{item['id']}.webp",
            'audio': None
        }
        manifest['words'].append(entry)
        added_count += 1

manifest['generatedAt'] = __import__('datetime').datetime.now().isoformat()

with open(manifest_path, 'w', encoding='utf-8') as f:
    json.dump(manifest, f, ensure_ascii=False, indent=1)

print(f"Manifest updated: {added_count} words added. Total words in manifest now: {len(manifest['words'])}")
