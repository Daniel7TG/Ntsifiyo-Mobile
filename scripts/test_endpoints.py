import os, sys
import requests

# DigitalOcean quedó archivado; el backend vivo hoy es el túnel ngrok que
# configura API_URL en lib/core/api/api_client.dart (rota de URL: verifica
# antes de correr esto).
API = os.environ.get("API_URL", "https://bottom-scenic-outcast.ngrok-free.dev")
TOKEN = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("TOKEN", "")
if not TOKEN:
    print("Usage: python scripts/test_endpoints.py <JWT_TOKEN>")
    sys.exit(1)
headers = {"Authorization": f"Bearer {TOKEN}"}

for ep in ["/api/games", "/api/games/MEMORY_GAME", "/api/games/topic/ANIMALS", "/api/activities/student"]:
    r = requests.get(f"{API}{ep}", headers=headers)
    print(f"{ep}: status={r.status_code}")
    if r.status_code == 200:
        try:
            print("  Body keys/len:", list(r.json().keys()) if isinstance(r.json(), dict) else len(r.json()))
        except Exception:
            print("  Body text:", r.text[:100])
    else:
        print("  Text:", r.text[:100])
