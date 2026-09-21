import json, os
m = json.load(open("assets/dictionary/manifest.json", "r", encoding="utf-8"))
print("Total words in manifest:", len(m["words"]))
for w in m["words"][:5]:
    print(f"  id={w['id']}  word={w['spanishWord']}  img={w['image']}  audio={w['audio']}")

img_files = os.listdir("assets/dictionary/img")
audio_files = os.listdir("assets/dictionary/audio")
print(f"Files in img/: {len(img_files)}")
print(f"Files in audio/: {len(audio_files)}")
print("Sample img:", img_files[:5])
print("Sample audio:", audio_files[:5])
