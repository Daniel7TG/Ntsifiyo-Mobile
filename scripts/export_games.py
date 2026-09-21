"""Exporta el catálogo completo de juegos del backend a
assets/games/manifest.json, para poblar CachedGames desde el primer
arranque sin depender de red — mismo principio que export_dictionary.py ya
aplica al diccionario.

Debe correr DESPUÉS de export_dictionary.py en el mismo release: reutiliza
assets/dictionary/manifest.json (recién regenerado) para resolver la media
de las palabras embebidas en cada juego contra las imágenes/audio YA
empaquetados del diccionario — los juegos usan exactamente las mismas
palabras, así que nada se descarga ni se copia dos veces. Las palabras que
no casen (caso raro: la pregunta usa una palabra fuera del diccionario, o el
match por id/nombre falla) se descargan aparte a `assets/games/media/`, para
que el bundle salga con `mediaComplete: true` de verdad y el primer arranque
no necesite red para ningún juego empaquetado.

`generatedAt` en el manifest queda con la fecha de esta corrida: por eso
debe correr justo antes de `flutter build`, no días antes.

El contenido de cada juego se baja con `GET /api/games/{id}/preview`, el
mismo endpoint que usa `GameCacheService.applyGameDelta` en el cliente: es
idéntico a `POST /api/activities/start/game/{id}` pero **no crea ninguna
actividad** en el servidor. Usar `start` aquí (como hacía este script antes)
ensuciaba la base de datos del backend con una partida fantasma por juego en
cada release, solo por generar el bundle.

GET /api/games (el listado paginado con `gameTopic` por juego, único lugar
con los metadatos de catálogo — título, tema, dificultad — que `/preview` no
trae) responde 403 para rol VISITOR — confirmado en vivo, es una
restricción de rol por diseño, no un bug (el payload trae datos de
asignación/profesor que no le corresponden a un visitante). Por eso este
script necesita credenciales de un rol con acceso (admin/estudiante), a
diferencia de export_dictionary.py.

Uso:
    export JNATRJO_CI_USERNAME=... JNATRJO_CI_PASSWORD=...
    python scripts/export_dictionary.py   # primero
    python scripts/export_games.py        # después

Requiere: pip install requests
"""

import argparse
import json
import os
import sys
from urllib.parse import urlparse

import requests

sys.path.insert(0, os.path.dirname(__file__))
from _ci_auth import login as ci_login  # noqa: E402

# Mismo default que api_client.dart / export_dictionary.py.
API = "https://bottom-scenic-outcast.ngrok-free.dev"
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "games")
MEDIA_DIR = os.path.join(OUT_DIR, "media")
DICTIONARY_MANIFEST = os.path.join(
    os.path.dirname(__file__), "..", "assets", "dictionary", "manifest.json"
)


def api_get(path, token):
    r = requests.get(f"{API}{path}", headers={"Authorization": f"Bearer {token}"}, timeout=60)
    r.raise_for_status()
    return r.json()


def download(url, timeout=120):
    r = requests.get(url, timeout=timeout)
    r.raise_for_status()
    return r.content


def normalize_word_name(s):
    return (s or "").strip().lower()


def load_dictionary_overlay():
    """Índice id→media y nombre-normalizado→media del manifest del
    diccionario ya generado en este mismo run. Mirror de
    _bundleMedia/_bundleMediaByName en dictionary_repository.dart."""
    if not os.path.exists(DICTIONARY_MANIFEST):
        print(
            "ADVERTENCIA: no existe assets/dictionary/manifest.json — corre "
            "export_dictionary.py antes que este script. Los juegos quedarán "
            "sin media empaquetada (se descargará en el primer arranque con red)."
        )
        return {}, {}
    with open(DICTIONARY_MANIFEST, "r", encoding="utf-8") as f:
        manifest = json.load(f)
    by_id, by_name = {}, {}
    for w in manifest.get("words", []):
        overlay = {
            "imageUrl": f"assets/dictionary/{w['image']}" if w.get("image") else None,
            "audioUrl": f"assets/dictionary/{w['audio']}" if w.get("audio") else None,
        }
        if w.get("id") is not None:
            by_id[w["id"]] = overlay
        name = normalize_word_name(w.get("spanishWord"))
        if name:
            by_name[name] = overlay
    return by_id, by_name


def apply_overlay(word, by_id, by_name):
    """Reescribe imageUrl/audioUrl de una palabra embebida en un juego para
    apuntar a la media YA empaquetada del diccionario, si existe — sin
    descargar ni copiar nada. Primero por id, luego por nombre normalizado
    (mismo fallback que _withBundleOverlay en Dart, por si el backend
    reasigna ids). Si no hay coincidencia, se deja la URL remota tal cual."""
    if not word:
        return
    word_id = word.get("id") or word.get("wordId")
    overlay = by_id.get(word_id) if word_id is not None else None
    if overlay is None:
        overlay = by_name.get(normalize_word_name(word.get("spanishWord")))
    if overlay is None:
        return
    if overlay.get("imageUrl"):
        word["imageUrl"] = overlay["imageUrl"]
    if overlay.get("audioUrl"):
        word["audioUrl"] = overlay["audioUrl"]


def rewrite_game_media(game_json, by_id, by_name):
    for w in game_json.get("words", []) or []:
        apply_overlay(w, by_id, by_name)
    for q in game_json.get("questions", []) or []:
        apply_overlay(q.get("word"), by_id, by_name)
        for a in q.get("responseList", []) or []:
            apply_overlay(a.get("word"), by_id, by_name)


def _words_in(game_json):
    """Todas las palabras embebidas en un juego (directas y dentro de
    preguntas/respuestas), en el mismo orden que recorre `rewrite_game_media`."""
    for w in game_json.get("words", []) or []:
        yield w
    for q in game_json.get("questions", []) or []:
        yield q.get("word")
        for a in q.get("responseList", []) or []:
            yield a.get("word")


def download_remaining_media(game_json):
    """Descarga a `assets/games/media/` la media que sigue con URL remota
    tras el overlay del diccionario — el caso raro que el docstring del
    módulo menciona. Sin esto el bundle salía con `mediaComplete: false`
    para esos juegos y el primer arranque necesitaba red para completarlos,
    exactamente lo que este script existe para evitar.

    Devuelve True si TODA la media del juego terminó local (bundle o recién
    descargada): eso es lo que decide `mediaComplete` en el manifest."""
    os.makedirs(MEDIA_DIR, exist_ok=True)
    complete = True
    for w in _words_in(game_json):
        if not w:
            continue
        word_id = w.get("id") or w.get("wordId") or "sinid"
        for field, kind in (("imageUrl", "img"), ("audioUrl", "audio")):
            url = w.get(field)
            if not url or not str(url).startswith("http"):
                continue
            ext = os.path.splitext(urlparse(url).path)[1] or (
                ".webp" if kind == "img" else ".mp3"
            )
            name = f"{word_id}{ext}"
            path = os.path.join(MEDIA_DIR, name)
            if not os.path.exists(path):
                try:
                    content = download(url)
                except Exception as e:
                    print(f"  ! no se pudo descargar {field} de la palabra {word_id}: {e}")
                    complete = False
                    continue
                with open(path, "wb") as f:
                    f.write(content)
            w[field] = f"assets/games/media/{name}"
    return complete


def main():
    global API
    parser = argparse.ArgumentParser()
    parser.add_argument("--api", default=API, help=f"Base URL del backend (default: {API})")
    args = parser.parse_args()
    API = args.api

    # /api/games exige admin/estudiante; visitante da 403 (confirmado, es
    # por diseño). start/game/{id} y el diccionario sí aceptan visitante,
    # pero este script necesita el listado paginado completo.
    token = ci_login(API, role="admin")

    by_id, by_name = load_dictionary_overlay()

    all_games = []
    page = 0
    while True:
        data = api_get(f"/api/games?page={page}", token)
        content = data.get("content", [])
        if not content:
            break
        all_games.extend(content)
        print(f"página {page}: {len(content)} juegos")
        if data.get("last", True):
            break
        page += 1

    print(f"\nTotal juegos: {len(all_games)}")

    manifest_games = []
    for g in all_games:
        game_id = g.get("id") or g.get("gameId")
        try:
            # /preview: mismo contenido que /activities/start/game/{id} pero
            # sin crear una actividad — ver el docstring del módulo.
            raw = api_get(f"/api/games/{game_id}/preview", token)
        except Exception as e:
            print(f"  ! preview game {game_id}: {e}")
            continue

        rewrite_game_media(raw, by_id, by_name)
        complete = download_remaining_media(raw)

        manifest_games.append({
            "gameId": game_id,
            "title": g.get("title", ""),
            "gameType": g.get("gameType") or g.get("type"),
            # El listado trae 'gameTopic', no 'topic' — mismo alias que ya
            # tolera GameSummaryDto.fromJson en Dart.
            "topic": g.get("gameTopic") or g.get("topic"),
            "difficult": g.get("difficult"),
            "experience": g.get("experience"),
            "totalQuestions": g.get("totalQuestions"),
            "mediaComplete": complete,
            "raw": raw,
        })
        print(f"  {game_id}: {g.get('title')}"
              + ("" if complete else " (media incompleta)"))

    os.makedirs(OUT_DIR, exist_ok=True)
    manifest = {
        "generatedAt": __import__("datetime").datetime.now().isoformat(),
        "games": manifest_games,
    }
    with open(os.path.join(OUT_DIR, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)

    total_size = os.path.getsize(os.path.join(OUT_DIR, "manifest.json"))
    print(f"\nListo: {len(manifest_games)} juegos, {total_size / 1024:.0f} KB en {OUT_DIR}")


if __name__ == "__main__":
    main()
