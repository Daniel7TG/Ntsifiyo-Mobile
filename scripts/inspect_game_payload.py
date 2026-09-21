import requests, json

API = "https://ntsifiyo-ltolw.ondigitalocean.app"
TOKEN = "eyJhbGciOiJIUzM4NCJ9.eyJyb2xlIjoiUk9MRV9TVFVERU5UIiwic3ViIjoiZS1sdWlzLXN1YXJlLTI1IiwiaWF0IjoxNzg1NTQ0NTUwLCJleHAiOjE3ODU2MzA5NTB9.3AqrGL-gRiUeWYH56AdLlXfFDR2x4SYfcN1fRl_bke495PPHlISgMJnKXaBCA_wN"
headers = {"Authorization": f"Bearer {TOKEN}"}

# Get games from ANIMALS topic
r = requests.get(f"{API}/api/games/topic/ANIMALS", headers=headers)
games = r.json().get("content", [])
print(f"Games in ANIMALS: {len(games)}")

for g in games[:3]:
    gid = g.get("id") or g.get("gameId")
    gtype = g.get("gameType") or g.get("type")
    title = g.get("title")
    print(f"\n=========================================")
    print(f"Game ID={gid} type={gtype} title='{title}'")
    print(f"=========================================")
    
    r2 = requests.post(f"{API}/api/activities/start/game/{gid}", headers=headers)
    if r2.status_code == 200:
        data = r2.json()
        print("Raw startGame JSON keys:", list(data.keys()))
        print("Full startGame JSON:\n", json.dumps(data, ensure_ascii=False, indent=2))
    else:
        print(f"Error {r2.status_code}: {r2.text}")
