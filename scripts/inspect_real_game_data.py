"""Fetch real games from backend, start one, and inspect the JSON payload and path resolution."""
import requests, json

API = "https://ntsifiyo-ltolw.ondigitalocean.app"
TOKEN = "eyJhbGciOiJIUzM4NCJ9.eyJyb2xlIjoiUk9MRV9TVFVERU5UIiwic3ViIjoiZS1sdWlzLXN1YXJlLTI1IiwiaWF0IjoxNzg1NTQ0NTUwLCJleHAiOjE3ODU2MzA5NTB9.3AqrGL-gRiUeWYH56AdLlXfFDR2x4SYfcN1fRl_bke495PPHlISgMJnKXaBCA_wN"
headers = {"Authorization": f"Bearer {TOKEN}"}

print("=== Fetching games list ===")
r = requests.get(f"{API}/api/games", headers=headers, timeout=30)
res = r.json()
games = res.get("games", res.get("content", res if isinstance(res, list) else []))
print(f"Total games: {len(games)}")

for g in games[:5]:
    gid = g.get("id") or g.get("gameId")
    gtype = g.get("gameType") or g.get("type")
    title = g.get("title")
    print(f"  Game ID={gid} type={gtype} title='{title}'")

for g0 in games[:3]:
    gid = g0.get("id") or g0.get("gameId")
    print(f"\n==================================================")
    print(f"=== Fetching startGame POST /api/activities/start/game/{gid} ===")
    print(f"==================================================")
    try:
        r2 = requests.post(f"{API}/api/activities/start/game/{gid}", headers=headers, timeout=30)
        data = r2.json()
        print("Top-level keys:", list(data.keys()))
        configs = data.get("gameConfigs") or data.get("gameconfigs") or data.get("gameConfigDTO")
        print("gameConfigs:", json.dumps(configs, indent=2))
        
        words = data.get("words", [])
        print(f"\nwords count: {len(words)}")
        for w in words[:3]:
            print(f"  Word: id={w.get('id') or w.get('wordId')} spanish='{w.get('spanishWord')}' mazahua='{w.get('mazahuaWord')}'")
            print(f"    imageUrl={w.get('imageUrl') or w.get('urlImage') or w.get('image')}")
            print(f"    audioUrl={w.get('audioUrl') or w.get('urlMazahuaAudio') or w.get('audio')}")
            print(f"    Raw word JSON: {json.dumps(w, ensure_ascii=False)}")
        
        questions = data.get("questions", [])
        print(f"\nquestions count: {len(questions)}")
        for q in questions[:3]:
            print(f"  Question: id={q.get('id')} q='{q.get('question')}' wordId={q.get('wordId')}")
            print(f"    word object: {json.dumps(q.get('word'), ensure_ascii=False)}")
            answers = q.get("responseList") or q.get("answers") or []
            print(f"    answers count: {len(answers)}")
            for a in answers[:3]:
                print(f"      Answer: id={a.get('id')} text='{a.get('answerText') or a.get('text')}' isCorrect={a.get('isCorrect')} wordId={a.get('wordId')}")
                print(f"        word object inside answer: {json.dumps(a.get('word'), ensure_ascii=False)}")
                print(f"        imageUrl={a.get('imageUrl') or a.get('urlImage')} audioUrl={a.get('audioUrl') or a.get('urlMazahuaAudio')}")
    except Exception as e:
        print(f"Error starting game {gid}: {e}")
