"""Script para sincronizar el campo pronunciation=true en el backend para todas las palabras
que coinciden con los centroides del modelo ONNX.

Uso:
    python scripts/sync_pronunciation_words.py --token <JWT>
    python scripts/sync_pronunciation_words.py --visitor <usuario> <password>
    python scripts/sync_pronunciation_words.py --student <numero_lista> <grado> <password>
"""

import argparse
import json
import os
import re
import sys
import requests

if hasattr(sys.stdout, 'reconfigure'):
    try:
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    except Exception:
        pass

def safe_print(msg):
    try:
        print(msg)
    except UnicodeEncodeError:
        print(msg.encode('ascii', errors='replace').decode('ascii'))

API_BASE = "https://ntsifiyo-ltolw.ondigitalocean.app"
MODEL_CONFIG_PATH = os.path.join(
    os.path.dirname(__file__), "..", "assets", "modelo", "centroides_y_config.json"
)

def normalize_key(key):
    return re.sub(r'[\s_\-]', '', key.strip().lower())

def load_centroids_words():
    if not os.path.exists(MODEL_CONFIG_PATH):
        print(f"Error: no se encontró {MODEL_CONFIG_PATH}")
        sys.exit(1)
    
    with open(MODEL_CONFIG_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    
    centroides = data.get("centroides", {})
    if isinstance(centroides, dict) and "palabras" in centroides:
        return [normalize_key(w) for w in centroides["palabras"]]
    elif isinstance(centroides, dict):
        return [normalize_key(k) for k in centroides.keys()]
    return []

def get_token(args):
    if args.token:
        return args.token
    
    if args.visitor:
        username, password = args.visitor
        url = f"{API_BASE}/api/auth/login/visitor"
        r = requests.post(url, json={"username": username, "password": password}, timeout=30)
        if r.status_code == 200:
            token = r.json().get("token") or r.json().get("jwt") or r.json().get("accessToken")
            print(f"Sesión iniciada exitosamente como visitante: {username}")
            return token
        else:
            print(f"Error al iniciar sesión como visitante: {r.status_code} - {r.text}")
            sys.exit(1)

    if args.student:
        list_num, grade, password = args.student
        url = f"{API_BASE}/api/auth/login/student"
        r = requests.post(url, json={"listNumber": int(list_num), "grade": int(grade), "password": password}, timeout=30)
        if r.status_code == 200:
            token = r.json().get("token") or r.json().get("jwt") or r.json().get("accessToken")
            print(f"Sesión iniciada exitosamente como estudiante")
            return token
        else:
            print(f"Error al iniciar sesión como estudiante: {r.status_code} - {r.text}")
            sys.exit(1)

    print("Por favor proporciona un token JWT (--token <JWT>) o credenciales de usuario.")
    print("Ejemplo: python scripts/sync_pronunciation_words.py --token <TU_TOKEN_JWT>")
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Sincroniza pronunciation=true en el backend")
    parser.add_argument("--token", help="Bearer JWT Token")
    parser.add_argument("--visitor", nargs=2, metavar=("USER", "PASS"), help="Credenciales visitante")
    parser.add_argument("--student", nargs=3, metavar=("LIST_NUM", "GRADE", "PASS"), help="Credenciales estudiante")
    args = parser.parse_args()

    token = get_token(args)
    headers = {"Authorization": f"Bearer {token}"}

    centroid_words = set(load_centroids_words())
    print(f"Cargadas {len(centroid_words)} palabras clave de centroides desde el modelo ONNX.")

    # 1. Obtener todas las categorías del diccionario
    try:
        r = requests.get(f"{API_BASE}/api/dictionary/words/categories", headers=headers, timeout=30)
        r.raise_for_status()
        categories = r.json().get("categories", [])
    except Exception as e:
        print(f"Error al consultar categorías con el token proporcionado: {e}")
        sys.exit(1)

    print(f"Categorías del backend: {categories}")

    all_words = []
    for cat in categories:
        page = 0
        while True:
            try:
                r = requests.get(f"{API_BASE}/api/dictionary/words/{cat}?page={page}", headers=headers, timeout=30)
                if r.status_code == 404:
                    break
                r.raise_for_status()
                data = r.json()
                words = data.get("words", data if isinstance(data, list) else [])
                if not words:
                    break
                all_words.extend(words)
                page += 1
            except Exception as e:
                print(f"  Error en categoría {cat} pág {page}: {e}")
                break

    print(f"Total palabras obtenidas del backend: {len(all_words)}")

    updated_count = 0
    matched_count = 0

    for w in all_words:
        word_id = w.get("id") or w.get("wordId")
        sp = normalize_key(w.get("spanishWord", ""))
        mz = normalize_key(w.get("mazahuaWord", ""))

        if sp in centroid_words or mz in centroid_words:
            matched_count += 1
            safe_print(f"-> Coincidencia [{word_id}]: {w.get('spanishWord')} / {w.get('mazahuaWord')}")
            
            # Enviar PUT /api/dictionary/word/{id}/media con multipart/form-data
            try:
                put_url = f"{API_BASE}/api/dictionary/word/{word_id}/media"
                files = {
                    'pronunciation': (None, 'true')
                }
                r_put = requests.put(put_url, files=files, headers=headers, timeout=30)
                if r_put.status_code in (200, 201, 204):
                    safe_print(f"   [OK] Actualizada en la nube wordId={word_id}")
                    updated_count += 1
                else:
                    safe_print(f"   [Status {r_put.status_code}] {r_put.text}")
            except Exception as e:
                safe_print(f"   [Error PUT] wordId={word_id}: {e}")

    safe_print(f"\nResumen: {matched_count} palabras coincidentes encontradas, {updated_count} actualizadas exitosamente en el servidor en la nube.")

if __name__ == "__main__":
    main()
