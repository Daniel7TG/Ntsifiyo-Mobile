"""Compare backend word IDs with manifest IDs to find mismatch."""
import os, sys
import requests, json

# DigitalOcean quedó archivado; el backend vivo hoy es el túnel ngrok que
# configura API_URL en lib/core/api/api_client.dart (rota de URL: verifica
# antes de correr esto).
API = os.environ.get("API_URL", "https://bottom-scenic-outcast.ngrok-free.dev")
TOKEN = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("TOKEN", "")
if not TOKEN:
    print("Usage: python scripts/compare_ids.py <JWT_TOKEN>")
    sys.exit(1)
headers = {"Authorization": f"Bearer {TOKEN}"}

# 1. Fetch first page of ANIMALS
r = requests.get(f"{API}/api/dictionary/words/ANIMALS?page=0", headers=headers, timeout=30)
data = r.json()
words = data.get("words", data.get("content", data if isinstance(data, list) else []))

print("=== Backend word structure (first 3) ===")
for w in words[:3]:
    wid = w.get("id")
    print(f"  id={wid} ({type(wid).__name__})  word={w.get('spanishWord')}")
    img = w.get("imageUrl") or w.get("urlImage") or w.get("image")
    aud = w.get("audioUrl") or w.get("urlMazahuaAudio") or w.get("audio")
    print(f"    image={img}")
    print(f"    audio={aud}")

# 2. Load manifest
m = json.load(open("assets/dictionary/manifest.json", "r", encoding="utf-8"))

print("\n=== Manifest word structure (first 3) ===")
for mw in m["words"][:3]:
    print(f"  id={mw['id']}  word={mw['spanishWord']}  img={mw.get('image')}")

# 3. Compare IDs for matching words
print("\n=== ID COMPARISON ===")
manifest_by_word = {w["spanishWord"]: w["id"] for w in m["words"]}

mismatches = 0
matches = 0
for w in words[:10]:
    name = w.get("spanishWord")
    backend_id = str(w.get("id"))
    manifest_id = manifest_by_word.get(name, "NOT_FOUND")
    match = backend_id == manifest_id
    if match:
        matches += 1
    else:
        mismatches += 1
    print(f"  {name:15s} backend={backend_id[:20]:22s} manifest={manifest_id[:20]:22s} {'OK' if match else 'MISMATCH!'}")

print(f"\nMatches: {matches}, Mismatches: {mismatches}")

# 4. Also fetch a game to see what wordIds it contains
print("\n=== Game word IDs ===")
try:
    r2 = requests.get(f"{API}/api/activities", headers=headers, timeout=30)
    games = r2.json()
    if isinstance(games, list) and len(games) > 0:
        game_id = games[0].get("id") or games[0].get("activityId")
        print(f"Fetching game {game_id}...")
        r3 = requests.get(f"{API}/api/activities/{game_id}/start", headers=headers, timeout=30)
        gdata = r3.json()
        gwords = gdata.get("words", [])
        gquestions = gdata.get("questions", [])
        if gwords:
            for gw in gwords[:3]:
                gwid = gw.get("id") or gw.get("wordId")
                print(f"  Game word: id={gwid}  name={gw.get('spanishWord')}")
                print(f"    imageUrl={gw.get('imageUrl') or gw.get('urlImage') or gw.get('image')}")
        if gquestions:
            for gq in gquestions[:2]:
                qw = gq.get("word", {})
                if qw:
                    print(f"  Game question word: id={qw.get('id')}  name={qw.get('spanishWord')}")
                    print(f"    imageUrl={qw.get('imageUrl') or qw.get('urlImage') or qw.get('image')}")
except Exception as e:
    print(f"  Could not fetch game: {e}")
