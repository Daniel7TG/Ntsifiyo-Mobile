"""Sube al backend las 20 palabras de números (0-10 y 20-100) con su imagen
PNG y su audio mp3.

Espejo de lo que hace la web al dar de alta una palabra del diccionario:
`POST /api/dictionary/word/media` (multipart) con `image`, `audio`,
`spanishText`, `mazahuaText` y `topic`.

Fuentes de cada pieza:

- Imagen: `assets/numbers/number_<n>.png`, generada con la CLI de Antigravity
  siguiendo `assets/numbers/ESTILO.md` (numeral como objeto 3D, sin rostro).
- Audio: `assets/numbers/audio/number_<n>.mp3`, convertido de los .wav de
  Matilde (0-10 de «Audios Maestros Organizados/numeros», 20-100 de
  «correciones/palabras», que son las tomas corregidas).
- Texto mazahua: dictado a mano, ver TEXTOS abajo.

Credenciales por variables de entorno, igual que el resto de scripts
(ver `_ci_auth.py`) — nunca por línea de comandos:

    export JNATRJO_CI_USERNAME=...
    export JNATRJO_CI_PASSWORD=...
    python scripts/upload_numbers.py --dry-run   # comprueba sin subir
    python scripts/upload_numbers.py

Requiere: pip install requests
"""

import argparse
import os
import sys

import requests

from _ci_auth import login

API_DEFAULT = "https://bottom-scenic-outcast.ngrok-free.dev"

# El backend no tiene categoría de números en las 8 que ya usa el diccionario
# (ANIMALS, PRONOUNS, CLOTHES, FOOD, FRUITS, BODY_PARTS, FIVE_SENSES, COLORS).
# Se sube con NUMBERS; si el enum del backend no lo acepta, el POST falla con
# 400 y el script lo reporta en vez de inventar otra categoría.
TOPIC = "NUMBERS"

# (n, español, mazahua)
TEXTOS = [
    (0, "cero", "otrjo"),
    (1, "uno", "naja"),
    (2, "dos", "yeje"),
    (3, "tres", "jñii"),
    (4, "cuatro", "nziyo"),
    (5, "cinco", "tsicha"),
    (6, "seis", "ñanto"),
    (7, "siete", "yencho"),
    (8, "ocho", "jñincho"),
    (9, "nueve", "nzincho"),
    (10, "diez", "dyecha"),
    (20, "veinte", "dyote"),
    (30, "treinta", "dyote dyecha"),
    (40, "cuarenta", "yeche"),
    (50, "cincuenta", "yeche dyecha"),
    (60, "sesenta", "jñiche"),
    (70, "setenta", "jñiche dyecha"),
    (80, "ochenta", "nziche"),
    (90, "noventa", "nziche dyecha"),
    (100, "cien", "zichiche"),
]

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_base_numbers = os.path.join(ROOT, "assets", "numbers")
if not os.path.exists(_base_numbers):
    _base_numbers = os.path.join(ROOT, "assets_backup", "numbers")
IMG_DIR = _base_numbers
AUDIO_DIR = os.path.join(_base_numbers, "audio")


def rutas(n):
    return (
        os.path.join(IMG_DIR, f"number_{n}.png"),
        os.path.join(AUDIO_DIR, f"number_{n}.mp3"),
    )


def revisar():
    """Comprueba que estén las 20 imágenes y los 20 audios antes de subir nada."""
    faltan = []
    for n, _, _ in TEXTOS:
        img, audio = rutas(n)
        if not os.path.isfile(img):
            faltan.append(os.path.relpath(img, ROOT))
        elif os.path.getsize(img) < 10_000:
            faltan.append(f"{os.path.relpath(img, ROOT)} (pesa menos de 10KB)")
        if not os.path.isfile(audio):
            faltan.append(os.path.relpath(audio, ROOT))
    return faltan


def subir(api, token, n, es, mz):
    img, audio = rutas(n)
    with open(img, "rb") as fi, open(audio, "rb") as fa:
        resp = requests.post(
            f"{api}/api/dictionary/word/media",
            headers={"Authorization": f"Bearer {token}"},
            data={"spanishText": es, "mazahuaText": mz, "topic": TOPIC},
            files={
                "image": (f"number_{n}.png", fi, "image/png"),
                "audio": (f"number_{n}.mp3", fa, "audio/mpeg"),
            },
            timeout=90,
        )
    resp.raise_for_status()
    return resp.json()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", default=os.environ.get("JNATRJO_API", API_DEFAULT))
    ap.add_argument(
        "--dry-run",
        action="store_true",
        help="comprueba archivos y credenciales sin subir nada",
    )
    args = ap.parse_args()

    faltan = revisar()
    if faltan:
        print(f"Faltan {len(faltan)} archivos; no se sube nada:")
        for f in faltan:
            print("  -", f)
        return 1
    print(f"OK: las {len(TEXTOS)} imágenes y los {len(TEXTOS)} audios están completos.")

    if args.dry_run:
        print(f"\n--dry-run: esto es lo que se subiría a {args.api} (topic={TOPIC}):")
        for n, es, mz in TEXTOS:
            img, audio = rutas(n)
            print(
                f"  {n:>3}  {es:<10} {mz:<16} "
                f"{os.path.getsize(img)//1024:>4}KB png  "
                f"{os.path.getsize(audio)//1024:>3}KB mp3"
            )
        return 0

    token = login(args.api, role="admin")
    ok, err = 0, []
    for n, es, mz in TEXTOS:
        try:
            subir(args.api, token, n, es, mz)
            print(f"  subido {n:>3}  {es} / {mz}")
            ok += 1
        except requests.HTTPError as e:
            cuerpo = e.response.text[:200] if e.response is not None else ""
            err.append((n, f"{e} {cuerpo}"))
            print(f"  FALLO  {n:>3}  {e}")

    print(f"\n{ok}/{len(TEXTOS)} subidas correctamente.")
    if err:
        print("Fallaron:")
        for n, e in err:
            print(f"  {n}: {e}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
