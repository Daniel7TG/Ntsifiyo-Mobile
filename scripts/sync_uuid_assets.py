"""Download dictionary from backend, assign UUID ids, rename asset files, update manifest."""
import os, sys, io, json, uuid, shutil
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
    print("Usage: python scripts/sync_uuid_assets.py <JWT_TOKEN> [--prune]")
    sys.exit(1)

headers = {"Authorization": f"Bearer {TOKEN}"}
OUT_DIR = os.path.join("assets", "dictionary")
IMG_DIR = os.path.join(OUT_DIR, "img")
AUDIO_DIR = os.path.join(OUT_DIR, "audio")
os.makedirs(IMG_DIR, exist_ok=True)
os.makedirs(AUDIO_DIR, exist_ok=True)

NAMESPACE = uuid.UUID("6ba7b810-9dad-11d1-80b4-00c04fd430c8")

# 1. Fetch categories
res = requests.get(f"{API}/api/dictionary/words/categories", headers=headers, timeout=30)
res.raise_for_status()
categories = res.json().get("categories", [])
print(f"Categorias: {categories}")

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

# 3. Process each word: rename or download files
manifest_words = []
stats = {"renamed_img": 0, "renamed_aud": 0, "dl_img": 0, "dl_aud": 0}

for w in all_words:
    raw_id = str(w.get("id") or w.get("wordId"))
    word_uuid = str(uuid.uuid5(NAMESPACE, f"jnatrjo.word.{raw_id}"))

    img_rel = None
    aud_rel = None

    # --- IMAGE ---
    uuid_img = os.path.join(IMG_DIR, f"{word_uuid}.webp")
    old_img = os.path.join(IMG_DIR, f"{raw_id}.webp")

    if os.path.exists(uuid_img) and os.path.getsize(uuid_img) > 0:
        img_rel = f"img/{word_uuid}.webp"
    elif os.path.exists(old_img) and os.path.getsize(old_img) > 0:
        shutil.copy2(old_img, uuid_img)
        img_rel = f"img/{word_uuid}.webp"
        stats["renamed_img"] += 1
    else:
        img_url = w.get("imageUrl") or w.get("image")
        if img_url and img_url.startswith("http"):
            try:
                resp = requests.get(img_url, timeout=30)
                if resp.status_code == 200:
                    im = Image.open(io.BytesIO(resp.content)).convert("RGBA")
                    im.thumbnail((600, 600), Image.LANCZOS)
                    im.save(uuid_img, "WEBP", quality=80)
                    img_rel = f"img/{word_uuid}.webp"
                    stats["dl_img"] += 1
            except Exception as e:
                print(f"  ! img {raw_id}: {e}")

    # --- AUDIO ---
    uuid_aud = os.path.join(AUDIO_DIR, f"{word_uuid}.mp3")
    old_aud = os.path.join(AUDIO_DIR, f"{raw_id}.mp3")

    if os.path.exists(uuid_aud) and os.path.getsize(uuid_aud) > 0:
        aud_rel = f"audio/{word_uuid}.mp3"
    elif os.path.exists(old_aud) and os.path.getsize(old_aud) > 0:
        shutil.copy2(old_aud, uuid_aud)
        aud_rel = f"audio/{word_uuid}.mp3"
        stats["renamed_aud"] += 1
    else:
        aud_url = w.get("audioUrl") or w.get("audio")
        if aud_url and aud_url.startswith("http"):
            try:
                resp = requests.get(aud_url, timeout=30)
                if resp.status_code == 200:
                    with open(uuid_aud, "wb") as f:
                        f.write(resp.content)
                    aud_rel = f"audio/{word_uuid}.mp3"
                    stats["dl_aud"] += 1
            except Exception as e:
                print(f"  ! aud {raw_id}: {e}")

    manifest_words.append({
        "id": word_uuid,
        "spanishWord": w.get("spanishWord", ""),
        "mazahuaWord": w.get("mazahuaWord", ""),
        "spanishPronunciation": w.get("spanishPronunciation"),
        "mazahuaPronunciation": w.get("mazahuaPronunciation"),
        "category": w["_category"],
        "image": img_rel,
        "audio": aud_rel,
    })

# 4. Write manifest
manifest = {
    "generatedAt": __import__("datetime").datetime.now().isoformat(),
    "categories": categories,
    "words": manifest_words,
}
with open(os.path.join(OUT_DIR, "manifest.json"), "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=1)

# 5. Delete old numeric files — solo con --prune (ver sync_backend_assets.py:
# estos dos scripts se borran los assets el uno al otro si se corren en
# secuencia sin este flag).
deleted = 0
if PRUNE:
    for d in [IMG_DIR, AUDIO_DIR]:
        for fname in os.listdir(d):
            stem = fname.rsplit(".", 1)[0]
            if stem.isdigit():
                os.remove(os.path.join(d, fname))
                deleted += 1
else:
    print("\n(--prune no indicado: no se borró ningún archivo existente)")

# 6. Summary
print(f"\n=== RESULTADO ===")
print(f"Palabras en manifest: {len(manifest_words)}")
print(f"Imgs copiadas (num->uuid): {stats['renamed_img']}")
print(f"Auds copiados (num->uuid): {stats['renamed_aud']}")
print(f"Imgs descargadas: {stats['dl_img']}")
print(f"Auds descargados: {stats['dl_aud']}")
print(f"Archivos numericos eliminados: {deleted}")

final_imgs = len([f for f in os.listdir(IMG_DIR) if not f.startswith(".")])
final_auds = len([f for f in os.listdir(AUDIO_DIR) if not f.startswith(".")])
print(f"Archivos finales: img={final_imgs}, audio={final_auds}")

sample = manifest_words[0]
print(f"Ejemplo: id={sample['id']}, img={sample['image']}, aud={sample['audio']}")
