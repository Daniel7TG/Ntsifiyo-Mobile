import csv
import json
import os
import re
import subprocess

csv_path = r"C:\Users\odtgo\Desktop\App Mazahua\Mazahua\Audios Niños\puntuaciones.csv"
audio_out_dir = r"assets\dictionary\audio"
manifest_path = r"assets\dictionary\manifest.json"

words_map = [
    {'id': 301, 'target': 'agua', 'aliases': ['agua']},
    {'id': 302, 'target': 'arroz', 'aliases': ['arroz']},
    {'id': 303, 'target': 'huevo', 'aliases': ['huevo']},
    {'id': 304, 'target': 'la mano', 'aliases': ['laMano', 'mano']},
    {'id': 305, 'target': 'mole', 'aliases': ['mole']},
    {'id': 306, 'target': 'pollito', 'aliases': ['pollito']},
    {'id': 307, 'target': 'queso', 'aliases': ['queso']},
    {'id': 308, 'target': 'salsa', 'aliases': ['salsa']},
    {'id': 309, 'target': 'zapato', 'aliases': ['zapato']},
    {'id': 310, 'target': 'zapato huarache', 'aliases': ['zapato-huarache', 'huarache']}
]

def norm(s):
    return re.sub(r'[\s_\-]', '', str(s).lower())

if not os.path.exists(csv_path):
    print(f"Error: no se encontró {csv_path}")
    exit(1)

with open(csv_path, 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    rows = list(reader)

os.makedirs(audio_out_dir, exist_ok=True)

print("1. Seleccionando y convirtiendo audios a MP3...")

selected_audios = {}

for w in words_map:
    aliases = [norm(a) for a in w['aliases']]
    matching_rows = []
    for r in rows:
        p_norm = norm(r.get('palabra', ''))
        if p_norm in aliases:
            score = int(r.get('puntuacion', 0))
            fp = r.get('archivo', '').strip()
            if os.path.exists(fp):
                matching_rows.append((score, r.get('nino'), r.get('palabra'), fp))
    
    matching_rows.sort(key=lambda x: x[0], reverse=True)
    if not matching_rows:
        print(f"  [ALERTA] No se encontró audio para ID {w['id']} ({w['target']})")
        continue

    best_score, nino, csv_word, wav_path = matching_rows[0]
    mp3_filename = f"{w['id']}.mp3"
    mp3_path = os.path.join(audio_out_dir, mp3_filename)

    # Convert WAV to MP3 using ffmpeg
    cmd = ['ffmpeg', '-y', '-i', wav_path, '-b:a', '128k', mp3_path]
    res = subprocess.run(cmd, capture_output=True, text=True)

    if res.returncode == 0 and os.path.exists(mp3_path):
        size = os.path.getsize(mp3_path)
        print(f"  [OK] ID {w['id']} ({w['target']}): Score {best_score} | {nino} -> {mp3_filename} ({size} bytes)")
        selected_audios[w['id']] = f"audio/{mp3_filename}"
    else:
        print(f"  [ERROR] Falló conversión ffmpeg para ID {w['id']}: {res.stderr}")

print("\n2. Actualizando manifest.json con las rutas de audio...")
with open(manifest_path, 'r', encoding='utf-8') as f:
    manifest = json.load(f)

updated_count = 0
for word_entry in manifest['words']:
    wid = word_entry.get('id')
    if wid in selected_audios:
        word_entry['audio'] = selected_audios[wid]
        updated_count += 1

manifest['generatedAt'] = __import__('datetime').datetime.now().isoformat()

with open(manifest_path, 'w', encoding='utf-8') as f:
    json.dump(manifest, f, ensure_ascii=False, indent=1)

print(f"Manifest actualizado: {updated_count} entradas recibieron su audio de referencia.")
