"""Make short Sarvam (Bulbul) voice samples of one narration line, for several speakers.

Usage (from the repo root):
    python -I -X utf8 scriptures/animation/tools/voice_test.py                 # default speakers
    python -I -X utf8 scriptures/animation/tools/voice_test.py ritu priya      # chosen speakers

Reads SARVAM_API_KEY from scriptures/animation/.env (git-ignored). The key is never printed.
Writes scriptures/animation/out/voice-test/<model>_<speaker>.wav (git-ignored).
"""
import base64
import json
import os
import sys

import requests

HERE = os.path.dirname(os.path.abspath(__file__))
ANIM = os.path.join(HERE, "..")
OUT = os.path.join(ANIM, "out", "voice-test")
URL = "https://api.sarvam.ai/text-to-speech"

# A line with the hard-to-pronounce names, taken from the m-saravana script.
TEXT = ("On Mount Kailasa, Shiva let fall sparks of fire from the eyes in the foreheads of his six faces. "
        "They spread across the whole of heaven and earth, and came to rest in the Saravana, "
        "the lake of reeds, where Murugan was born.")

# Speaker names are from Sarvam's bulbul:v3 list; gender is not stated in the docs, so we listen.
DEFAULT_SPEAKERS = ["ritu", "priya", "neha", "pooja", "simran", "kavya", "ishita", "shreya", "roopa", "kavitha"]


def load_key():
    path = os.path.join(ANIM, ".env")
    if os.path.exists(path):
        for line in open(path, encoding="utf-8"):
            line = line.strip()
            if line.startswith("SARVAM_API_KEY="):
                return line.split("=", 1)[1].strip().strip('"').strip("'")
    return os.environ.get("SARVAM_API_KEY", "")


def synth(key, speaker, model="bulbul:v3", pace=0.95):
    headers = {"api-subscription-key": key, "Content-Type": "application/json"}
    last = None
    for lang_field in ("target_language_code", "language_code"):
        body = {"text": TEXT, lang_field: "en-IN", "speaker": speaker, "model": model,
                "pace": pace, "speech_sample_rate": 24000}
        r = requests.post(URL, headers=headers, json=body, timeout=120)
        last = r
        if r.status_code == 200:
            ctype = r.headers.get("content-type", "")
            if "audio" in ctype:
                return r.content
            data = r.json()
            audios = data.get("audios") or data.get("audio")
            if isinstance(audios, list):
                audios = audios[0]
            return base64.b64decode(audios)
        if r.status_code not in (400, 422):
            break
    raise RuntimeError(f"HTTP {last.status_code}: {last.text[:200]}")


def main():
    key = load_key()
    if not key:
        print("No SARVAM_API_KEY found. Put it in scriptures/animation/.env (see .env.example).")
        return 1
    speakers = sys.argv[1:] or DEFAULT_SPEAKERS
    os.makedirs(OUT, exist_ok=True)
    for sp in speakers:
        try:
            audio = synth(key, sp)
            path = os.path.join(OUT, f"bulbul-v3_{sp}.wav")
            open(path, "wb").write(audio)
            print(f"ok   {sp:10} {len(audio)//1024} KB -> {os.path.relpath(path)}")
        except Exception as e:  # keep going: some names may not exist for this model
            print(f"fail {sp:10} {e}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
