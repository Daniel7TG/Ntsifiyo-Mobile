"""
Download dictionary from backend, assign real backend integer IDs, save asset files as {raw_id}.webp / {raw_id}.mp3, and update manifest.json with integer IDs.
"""
import os
import sys
import io
import json
import shutil
import requests
from PIL import Image

# DigitalOcean quedó archivado; el backend vivo hoy es el túnel ngrok que
# configura API_URL en lib/core/api/api_client.dart (rota de URL: verifica
# antes de correr esto).
API = os.environ.get("API_URL", "https://bottom-scenic-outcast.ngrok-free.dev")
_args = [a for a in sys.argv[1:] if not a.startswith("--")]
PRUNE = "--prune" in sys.argv[1:]
TOKEN = _args[0] if _args else os.environ.get("TOKEN", "")
if not TOKEN:
    print("Usage: python scripts/sync_backend_assets.py <JWT_TOKEN> [--prune]")
    sys.exit(1)

headers = {"Authorization": f"Bearer {TOKEN}"}
OUT_DIR = os.path.join("assets", "dictionary")
IMG_DIR = os.path.join(OUT_DIR, "img")
AUDIO_DIR = os.path.join(OUT_DIR, "audio")
os.makedirs(IMG_DIR, exist_ok=True)
os.makedirs(AUDIO_DIR, exist_ok=True)

# 1. Fetch categories
res = requests.get(f"{API}/api/dictionary/words/categories", headers=headers, timeout=30)
res.raise_for_status()
categories = res.json().get("categories", [])
print(f"Categorías: {categories}")

# 2. Fetch all words
all_words = []
for category in categories:
    page = 0
    while True:
        r = requests.get(f"{API}/api/dictionary/words/{category}?page={page}", headers=headers, timeout=30)
        if r.status_code == 404:
            break
        r.raise_for_status()
        data = r.json()
        words = data.get("words", data.get("content", data if isinstance(data, list) else []))
        if not words:
            break
        print(f"  [{category}] p{page}: {len(words)} palabras")
        for w in words:
            w["_category"] = category
        all_words.extend(words)
        page += 1

print(f"\nTotal palabras del backend: {len(all_words)}")

manifest_words = []
stats = {"dl_img": 0, "dl_aud": 0}

for w in all_words:
    raw_id = int(w.get("id") or w.get("wordId"))
    word_name = w.get("spanishWord", "")

    img_rel = None
    aud_rel = None

    # --- IMAGE ---
    raw_img_path = os.path.join(IMG_DIR, f"{raw_id}.webp")
    if os.path.exists(raw_img_path) and os.path.getsize(raw_img_path) > 0:
        img_rel = f"img/{raw_id}.webp"
    else:
        img_url = w.get("imageUrl") or w.get("urlImage") or w.get("image")
        if img_url and img_url.startswith("http"):
            try:
                resp = requests.get(img_url, timeout=30)
                if resp.status_code == 200:
                    im = Image.open(io.BytesIO(resp.content)).convert("RGBA")
                    im.thumbnail((600, 600), Image.LANCZOS)
                    im.save(raw_img_path, "WEBP", quality=80)
                    img_rel = f"img/{raw_id}.webp"
                    stats["dl_img"] += 1
            except Exception as e:
                print(f"  ! Error descargando imagen para {raw_id} ({word_name}): {e}")

    # --- AUDIO ---
    raw_aud_path = os.path.join(AUDIO_DIR, f"{raw_id}.mp3")
    if os.path.exists(raw_aud_path) and os.path.getsize(raw_aud_path) > 0:
        aud_rel = f"audio/{raw_id}.mp3"
    else:
        aud_url = w.get("audioUrl") or w.get("urlMazahuaAudio") or w.get("audio")
        if aud_url and aud_url.startswith("http"):
            try:
                resp = requests.get(aud_url, timeout=30)
                if resp.status_code == 200:
                    with open(raw_aud_path, "wb") as f:
                        f.write(resp.content)
                    aud_rel = f"audio/{raw_id}.mp3"
                    stats["dl_aud"] += 1
            except Exception as e:
                print(f"  ! Error descargando audio para {raw_id} ({word_name}): {e}")

    manifest_words.append({
        "id": raw_id,  # INT ID
        "spanishWord": word_name,
        "mazahuaWord": w.get("mazahuaWord", ""),
        "spanishPronunciation": w.get("spanishPronunciation"),
        "mazahuaPronunciation": w.get("mazahuaPronunciation"),
        "category": w["_category"],
        "image": img_rel,
        "audio": aud_rel,
    })

# 3. Write manifest.json with integer IDs
manifest = {
    "generatedAt": __import__("datetime").datetime.now().isoformat(),
    "categories": categories,
    "words": manifest_words,
}
with open(os.path.join(OUT_DIR, "manifest.json"), "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=1)

# 4. Clean non-digit filenames — solo con --prune: sin ese flag este script
# y sync_uuid_assets.py se borran los assets el uno al otro (numérico vs
# UUID) si se corren en secuencia con el backend caído.
deleted_files = 0
if PRUNE:
    for d in [IMG_DIR, AUDIO_DIR]:
        for fname in os.listdir(d):
            stem = fname.rsplit(".", 1)[0]
            if not stem.isdigit():
                try:
                    os.remove(os.path.join(d, fname))
                    deleted_files += 1
                except Exception as e:
                    print(f"  ! Error borrando {fname}: {e}")
else:
    print("\n(--prune no indicado: no se borró ningún archivo existente)")

print("\n=== RESULTADO ===")
print(f"Palabras en manifest: {len(manifest_words)}")
print(f"Ejemplo palabra 1: id={manifest_words[0]['id']} (type: {type(manifest_words[0]['id']).__name__})")
