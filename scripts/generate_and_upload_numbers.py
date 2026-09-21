import os
import sys
import io
import math
import json
import colorsys
import requests
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

API = "https://ntsifiyo-ltolw.ondigitalocean.app"
TOKEN = "eyJhbGciOiJIUzM4NCJ9.eyJyb2xlIjoiUk9MRV9BRE1JTiIsInN1YiI6InJvb3QiLCJpYXQiOjE3ODU2MTgwODcsImV4cCI6MTc4NTcwNDQ4N30.hHJsE9nJ5rvyA-hwplE4yZ3zg3fkA9u0LybVkqwtvmCbhQi8MK9QQQwvTmxfCIRF"

OUT_DIR = "generated_numbers"
os.makedirs(OUT_DIR, exist_ok=True)

FONT_PATH = "assets/fonts/Poppins-Black.ttf"


def get_number_words(n):
    units_es = [
        "cero", "uno", "dos", "tres", "cuatro",
        "cinco", "seis", "siete", "ocho", "nueve"
    ]
    units_mz = [
        "otrjo", "naja", "yeje", "jñii", "nziyo",
        "tsicha", "ñanto", "yencho", "jñincho", "nzincho"
    ]

    if n == 0:
        return "cero", "otrjo"
    if n == 100:
        return "cien", "zichiche"

    teens_es = {
        10: "diez", 11: "once", 12: "doce", 13: "trece", 14: "catorce",
        15: "quince", 16: "dieciséis", 17: "diecisiete", 18: "dieciocho", 19: "diecinueve"
    }

    tens_es_base = {
        2: "veinte", 3: "treinta", 4: "cuarenta", 5: "cincuenta",
        6: "sesenta", 7: "setenta", 8: "ochenta", 9: "noventa"
    }

    tens_mz_base = {
        1: "dyecha",
        2: "dyote",
        3: "Dyote dyecha",
        4: "yeche",
        5: "yeche dyecha",
        6: "jñiche",
        7: "jñiche dyecha",
        8: "nziche",
        9: "nziche dyecha"
    }

    if 1 <= n <= 9:
        return units_es[n], units_mz[n]
    if 10 <= n <= 19:
        es = teens_es[n]
        if n == 10:
            mz = "dyecha"
        else:
            mz = f"dyecha {units_mz[n % 10]}"
        return es, mz

    tens_digit = n // 10
    unit_digit = n % 10

    if unit_digit == 0:
        return tens_es_base[tens_digit], tens_mz_base[tens_digit]
    else:
        if tens_digit == 2:
            veinti_es = {
                1: "veintiuno", 2: "veintidós", 3: "veintitrés", 4: "veinticuatro",
                5: "veinticinco", 6: "veintiséis", 7: "veintisiete", 8: "veintiocho", 9: "veintinueve"
            }
            es = veinti_es[unit_digit]
        else:
            es = f"{tens_es_base[tens_digit]} y {units_es[unit_digit]}"

        mz_prefix = tens_mz_base[tens_digit]
        mz = f"{mz_prefix} {units_mz[unit_digit]}"
        return es, mz


def generate_sticker(number_str, num_val, size=600):
    W, H = size, size

    # Golden ratio hue distribution for vibrant unique colors
    h1 = (num_val * 0.381966) % 1.0
    h2 = (h1 + 0.12) % 1.0
    h3 = (h1 + 0.25) % 1.0

    c1 = [int(c * 255) for c in colorsys.hsv_to_rgb(h1, 0.85, 1.0)]
    c2 = [int(c * 255) for c in colorsys.hsv_to_rgb(h2, 0.90, 0.92)]
    c3 = [int(c * 255) for c in colorsys.hsv_to_rgb(h3, 0.95, 0.70)]

    if len(number_str) == 1:
        font_size = 360
    elif len(number_str) == 2:
        font_size = 275
    else:
        font_size = 210

    font = ImageFont.truetype(FONT_PATH, font_size)

    dummy_img = Image.new('RGBA', (W, H))
    dummy_draw = ImageDraw.Draw(dummy_img)
    bbox = dummy_draw.textbbox((0, 0), number_str, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = (W - tw) // 2 - bbox[0]
    ty = (H - th) // 2 - bbox[1] - 10

    text_mask_img = Image.new('L', (W, H), 0)
    draw_mask = ImageDraw.Draw(text_mask_img)
    draw_mask.text((tx, ty), number_str, fill=255, font=font)

    dilated_mask = text_mask_img.filter(ImageFilter.MaxFilter(size=45))
    dilated_mask = dilated_mask.filter(ImageFilter.GaussianBlur(radius=3.0))
    dilated_arr = np.array(dilated_mask)
    sticker_mask_arr = np.where(dilated_arr > 60, 255, 0).astype(np.uint8)
    sticker_mask = Image.fromarray(sticker_mask_arr, 'L').filter(ImageFilter.GaussianBlur(radius=1.5))

    cy, cx = int(H * 0.28), int(W * 0.32)
    y_grid, x_grid = np.ogrid[:H, :W]
    dist = np.sqrt((x_grid - cx) ** 2 + (y_grid - cy) ** 2)
    max_r = np.sqrt(W ** 2 + H ** 2) * 0.55
    t = np.clip(dist / max_r, 0, 1)
    t_curved = t * t * (3 - 2 * t)

    fill_arr = np.zeros((H, W, 4), dtype=np.uint8)
    mask_in = t_curved < 0.5
    t1 = t_curved[mask_in] * 2
    t2 = (t_curved[~mask_in] - 0.5) * 2

    for c_idx in range(3):
        cin, cmid, cout = c1[c_idx], c2[c_idx], c3[c_idx]
        col_chan = np.zeros((H, W), dtype=np.float32)
        col_chan[mask_in] = cin + (cmid - cin) * t1
        col_chan[~mask_in] = cmid + (cout - cmid) * t2
        fill_arr[:, :, c_idx] = np.clip(col_chan, 0, 255).astype(np.uint8)
    fill_arr[:, :, 3] = 255
    grad_fill = Image.fromarray(fill_arr, 'RGBA')

    canvas = Image.new('RGBA', (W, H), (0, 0, 0, 0))

    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.bitmap((0, 10), sticker_mask, fill=(15, 15, 35, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=12))
    canvas.alpha_composite(shadow)

    white_border = Image.new('RGBA', (W, H), (255, 255, 255, 255))
    canvas.paste(white_border, (0, 0), sticker_mask)

    inner_stroke_mask = ImageChops.subtract(sticker_mask, ImageChops.offset(sticker_mask, 0, -4))
    inner_stroke = Image.new('RGBA', (W, H), (210, 215, 225, 255))
    canvas.paste(inner_stroke, (0, 0), inner_stroke_mask)

    number_comp = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    number_comp.paste(grad_fill, (0, 0), text_mask_img)

    sheen_mask = Image.new('L', (W, H), 0)
    sheen_draw = ImageDraw.Draw(sheen_mask)
    sheen_draw.ellipse([tx - 40, ty - 60, tx + tw + 40, ty + int(th * 0.48)], fill=85)
    sheen_mask = ImageChops.multiply(sheen_mask, text_mask_img)
    sheen_layer = Image.new('RGBA', (W, H), (255, 255, 255, 255))
    number_comp.paste(sheen_layer, (0, 0), sheen_mask)

    bevel_mask = ImageChops.subtract(text_mask_img, ImageChops.offset(text_mask_img, -3, -3))
    bevel_layer = Image.new('RGBA', (W, H), (0, 0, 0, 70))
    number_comp.paste(bevel_layer, (0, 0), bevel_mask)

    canvas.alpha_composite(number_comp)

    sparkle_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    sp_draw = ImageDraw.Draw(sparkle_layer)

    def draw_star(cx, cy, r_outer, r_inner):
        pts = []
        for i in range(8):
            angle = i * math.pi / 4
            r = r_outer if i % 2 == 0 else r_inner
            pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
        sp_draw.polygon(pts, fill=(255, 255, 255, 240))
        sp_draw.ellipse([cx - r_inner, cy - r_inner, cx + r_inner, cy + r_inner], fill=(255, 255, 255, 255))

    draw_star(bbox[0] + 5, bbox[1] + 10, 20, 4.5)
    draw_star(bbox[2] - 5, bbox[1] + 18, 16, 3.5)

    sp_draw.ellipse([bbox[0] - 18, bbox[3] - 35, bbox[0] - 6, bbox[3] - 23], fill=(c1[0], c1[1], c1[2], 230))
    sp_draw.ellipse([bbox[2] + 8, bbox[1] + 40, bbox[2] + 20, bbox[1] + 52], fill=(c2[0], c2[1], c2[2], 230))
    sp_draw.ellipse([bbox[2] + 15, bbox[3] - 20, bbox[2] + 23, bbox[3] - 12], fill=(255, 255, 255, 220))

    canvas.alpha_composite(sparkle_layer)

    file_path = os.path.join(OUT_DIR, f"number_{num_val}.webp")
    canvas.save(file_path, "WEBP", quality=85)
    return file_path


def upload_word(num_val, es_word, mz_word, image_path, sample_audio_bytes):
    url = f"{API}/api/dictionary/word/media"
    headers = {"Authorization": f"Bearer {TOKEN}"}

    with open(image_path, "rb") as img_file:
        files = {
            "image": (os.path.basename(image_path), img_file, "image/webp"),
            "audio": (f"number_{num_val}.mp3", sample_audio_bytes, "audio/mpeg")
        }
        data = {
            "spanishText": es_word,
            "mazahuaText": mz_word,
            "topic": "PRONOUNS"
        }
        res = requests.post(url, headers=headers, data=data, files=files, timeout=60)
        res.raise_for_status()
        return res.json()


def main():
    print("=== Fetching sample audio for payload compliance ===")
    audio_sample_url = "https://objectstorage.mx-queretaro-1.oraclecloud.com/p/AM0mmrB34CMOA3yfUJgZMR95bVPdr1kZ2yhg28GjkihKZJkjbOyBZ4UO3ban0Ajc/n/axceel8oki5w/b/bucket-20260205-2248/o/yo-maz.mp3"
    sample_audio_bytes = requests.get(audio_sample_url).content

    print("=== PASO 1: Generando 101 imágenes tipo sticker (0 a 100) ===")
    generated_files = {}
    for i in range(101):
        es_word, mz_word = get_number_words(i)
        img_path = generate_sticker(str(i), i)
        generated_files[i] = (es_word, mz_word, img_path)

    print("  [Imágenes] ¡101/101 imágenes generadas con éxito!")

    print("\n=== PASO 2: Subiendo 101 palabras e imágenes al backend ===")
    uploaded_words = []
    for i in range(101):
        es_word, mz_word, img_path = generated_files[i]
        try:
            resp = upload_word(i, es_word, mz_word, img_path, sample_audio_bytes)
            word_id = resp.get("id") or resp.get("wordId")
            print(f"  [{i:3d}/100] OK -> ID: {word_id} | ES: '{es_word}' | MZ: '{mz_word}'")
            uploaded_words.append(resp)
        except Exception as e:
            print(f"  ! ERROR subiendo número {i} ('{es_word}'): {e}")

    print(f"\n=== PROCESO FINALIZADO: {len(uploaded_words)}/101 números creados e imágenes subidas en el backend! ===")


if __name__ == "__main__":
    main()
