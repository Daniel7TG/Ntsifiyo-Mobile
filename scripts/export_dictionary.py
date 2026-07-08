"""Exporta el diccionario del backend a assets/dictionary/ para uso offline.

Descarga categorías, palabras, imágenes y audios; comprime imágenes a webp
(max 600px) para mantener el bundle < 50MB.

Uso:
    python scripts/export_dictionary.py --token <JWT>
    (obtén el JWT iniciando sesión en la web y copiando localStorage.authToken)

Requiere: pip install requests pillow
"""

import argparse
import io
import json
import os
import sys
from urllib.parse import urlparse

import requests

try:
    from PIL import Image
except ImportError:
    Image = None

API = "https://ntsifiyo-ltolw.ondigitalocean.app"
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "dictionary")
IMG_DIR = os.path.join(OUT_DIR, "img")
AUDIO_DIR = os.path.join(OUT_DIR, "audio")
MAX_IMG_SIZE = 600
WEBP_QUALITY = 80


def api_get(path, token):
    r = requests.get(f"{API}{path}", headers={"Authorization": f"Bearer {token}"}, timeout=60)
    r.raise_for_status()
    return r.json()


def download(url, timeout=120):
    r = requests.get(url, timeout=timeout)
    r.raise_for_status()
    return r.content


def save_image(content, word_id):
    name = f"{word_id}.webp"
    path = os.path.join(IMG_DIR, name)
    if Image is not None:
        try:
            im = Image.open(io.BytesIO(content)).convert("RGBA")
            im.thumbnail((MAX_IMG_SIZE, MAX_IMG_SIZE), Image.LANCZOS)
            im.save(path, "WEBP", quality=WEBP_QUALITY)
            return f"img/{name}"
        except Exception as e:
            print(f"  ! no se pudo convertir imagen {word_id}: {e}")
    # Fallback: guardar tal cual con su extensión original
    with open(path, "wb") as f:
        f.write(content)
    return f"img/{name}"


def save_audio(content, word_id, url):
    ext = os.path.splitext(urlparse(url).path)[1] or ".mp3"
    name = f"{word_id}{ext}"
    path = os.path.join(AUDIO_DIR, name)
    with open(path, "wb") as f:
        f.write(content)
    return f"audio/{name}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--token", required=True, help="JWT de un usuario válido")
    args = parser.parse_args()

    os.makedirs(IMG_DIR, exist_ok=True)
    os.makedirs(AUDIO_DIR, exist_ok=True)

    categories = api_get("/api/dictionary/words/categories", args.token).get("categories", [])
    print(f"Categorías: {categories}")

    manifest_words = []
    for category in categories:
        page = 0
        while True:
            try:
                data = api_get(f"/api/dictionary/words/{category}?page={page}", args.token)
            except requests.HTTPError as e:
                # El backend responde 404 al pasar la última página
                if e.response is not None and e.response.status_code == 404:
                    break
                raise
            words = data.get("words", data if isinstance(data, list) else [])
            if not words:
                break
            print(f"[{category}] página {page}: {len(words)} palabras")
            for w in words:
                word_id = w.get("id") or w.get("wordId")
                entry = {
                    "id": word_id,
                    "spanishWord": w.get("spanishWord", ""),
                    "mazahuaWord": w.get("mazahuaWord", ""),
                    "spanishPronunciation": w.get("spanishPronunciation"),
                    "mazahuaPronunciation": w.get("mazahuaPronunciation"),
                    "category": category,
                    "image": None,
                    "audio": None,
                }
                if w.get("imageUrl"):
                    try:
                        entry["image"] = save_image(download(w["imageUrl"]), word_id)
                    except Exception as e:
                        print(f"  ! imagen {word_id}: {e}")
                if w.get("audioUrl"):
                    try:
                        entry["audio"] = save_audio(download(w["audioUrl"]), word_id, w["audioUrl"])
                    except Exception as e:
                        print(f"  ! audio {word_id}: {e}")
                manifest_words.append(entry)
            page += 1

    manifest = {
        "generatedAt": __import__("datetime").datetime.now().isoformat(),
        "categories": categories,
        "words": manifest_words,
    }
    with open(os.path.join(OUT_DIR, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)

    total_size = sum(
        os.path.getsize(os.path.join(root, name))
        for root, _, files in os.walk(OUT_DIR)
        for name in files
    )
    print(f"\nListo: {len(manifest_words)} palabras, {total_size / 1024 / 1024:.1f} MB en {OUT_DIR}")
    if total_size > 50 * 1024 * 1024:
        print("ADVERTENCIA: el bundle supera los 50MB — baja WEBP_QUALITY o MAX_IMG_SIZE.")
        sys.exit(1)


if __name__ == "__main__":
    main()
