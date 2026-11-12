"""Original background music for the marketing video (synthesized, no samples, no licence needed).

Calm devotional feel: tanpura drone, soft pad, a bansuri-like flute melody in D Mohanam
(D E F# A B), a vina-like pluck, and a light frame-drum pulse. About 134 seconds.

    python make_music.py            # writes music-v2.wav next to this file
    ffmpeg -y -i music-v2.wav -c:a aac -b:a 192k ../remotion/public/music-v2.m4a

Replace the result with a licensed track at any time; the video only reads music-v2.m4a.
"""
import os
import numpy as np
from scipy.signal import fftconvolve, butter, sosfilt
from scipy.io import wavfile

SR = 48000
DUR = 134.0
BPM = 72
BEAT = 60.0 / BPM
rng = np.random.default_rng(7)
N = int(SR * DUR)
t_all = np.arange(N) / SR

# Mohanam on D. Frequencies in Hz.
D = {"D3": 146.83, "E3": 164.81, "F#3": 185.00, "A3": 220.00, "B3": 246.94,
     "D4": 293.66, "E4": 329.63, "F#4": 369.99, "A4": 440.00, "B4": 493.88,
     "D5": 587.33, "E5": 659.25, "F#5": 739.99, "A5": 880.00, "B5": 987.77, "D6": 1174.66,
     "A2": 110.00, "D2": 73.42, "B2": 123.47}


def env_adsr(n, a, r, sr=SR):
    e = np.ones(n)
    na, nr = min(n, int(a * sr)), min(n, int(r * sr))
    if na:
        e[:na] = np.linspace(0, 1, na) ** 1.5
    if nr:
        e[-nr:] *= np.linspace(1, 0, nr) ** 1.5
    return e


def add(buf, sig, start_s, gain=1.0, pan=0.0):
    i = int(start_s * SR)
    if i >= buf.shape[0]:
        return
    j = min(buf.shape[0], i + len(sig))
    s = sig[: j - i] * gain
    buf[i:j, 0] += s * (1 - max(0, pan))
    buf[i:j, 1] += s * (1 + min(0, pan))


def tanpura_pluck(freq, length=6.0):
    n = int(length * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for h in range(1, 17):
        amp = 1.0 / h ** 0.85
        # the jawari buzz: upper partials swell a little after the pluck and decay slowly
        swell = 1 + 0.9 * (h > 4) * np.exp(-((t - 0.35 * h / 4) ** 2) / 0.05)
        dec = np.exp(-t / (2.4 / h ** 0.35))
        out += amp * swell * dec * np.sin(2 * np.pi * freq * h * (1 + 0.0004 * h) * t + rng.uniform(0, 6.28))
    out *= np.minimum(1, t / 0.01)
    return out / np.max(np.abs(out))


def flute(freq, length, vib=0.0045):
    n = int(length * SR)
    t = np.arange(n) / SR
    vib_env = np.minimum(1, t / 0.5) * vib
    ph = 2 * np.pi * np.cumsum(freq * (1 + vib_env * np.sin(2 * np.pi * 5.1 * t))) / SR
    tone = np.sin(ph) + 0.28 * np.sin(2 * ph) + 0.10 * np.sin(3 * ph)
    breath = sosfilt(butter(2, [freq * 1.2, freq * 4], btype="band", fs=SR, output="sos"), rng.normal(size=n))
    breath *= 0.06 * (0.4 + np.minimum(1, t / 0.15))
    s = (tone + breath) * env_adsr(n, 0.09, 0.45)
    return s / 1.6


def vina(freq, length=2.2):
    n = int(length * SR)
    t = np.arange(n) / SR
    s = (np.sin(2 * np.pi * freq * t) + 0.45 * np.sin(2 * np.pi * 2 * freq * t) * np.exp(-t / 0.6)
         + 0.2 * np.sin(2 * np.pi * 3 * freq * t) * np.exp(-t / 0.25))
    return s * np.exp(-t / 0.9) * np.minimum(1, t / 0.004)


def frame_drum(length=0.7):
    n = int(length * SR)
    t = np.arange(n) / SR
    f = 62 + 70 * np.exp(-t / 0.05)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.18)
    s += 0.25 * sosfilt(butter(2, [200, 1200], btype="band", fs=SR, output="sos"), rng.normal(size=n)) * np.exp(-t / 0.03)
    return s


def shaker(length=0.12):
    n = int(length * SR)
    t = np.arange(n) / SR
    s = sosfilt(butter(2, 5000, btype="high", fs=SR, output="sos"), rng.normal(size=n))
    return s * np.exp(-t / 0.03) * np.minimum(1, t / 0.004)


def pad_chord(freqs, length):
    n = int(length * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f in freqs:
        for det in (-0.0035, 0.0, 0.0035):
            out += np.sin(2 * np.pi * f * (1 + det) * t + rng.uniform(0, 6.28))
    out *= env_adsr(n, 4.0, 4.0)
    out *= 0.85 + 0.15 * np.sin(2 * np.pi * t / 9.0)
    return out / (3 * len(freqs))


mix = np.zeros((N, 2))
drone = np.zeros((N, 2))
melody = np.zeros((N, 2))
perc = np.zeros((N, 2))

# --- tanpura: Pa, Sa, Sa, low Sa (about a 5.2 s cycle), the whole piece
cycle = [("A3", 0.0), ("D4", 1.25), ("D4", 2.5), ("D3", 3.75)]
tcur = 0.0
while tcur < DUR:
    for name, off in cycle:
        add(drone, tanpura_pluck(D[name]), tcur + off, 0.34, pan=0.15 if name == "D3" else -0.1)
    tcur += 5.2

# --- pad: alternating Dsus2 and Bm colour, enters at 6 s
chords = [[D["D3"], D["A3"], D["E4"]], [D["B2"], D["F#3"], D["D4"]]]
tcur, k = 6.0, 0
while tcur < DUR - 6:
    add(drone, pad_chord(chords[k % 2], 14.0), tcur, 0.55)
    tcur += 10.0
    k += 1

# --- flute melody, written in beats at 72 bpm: (note, beats). None is a rest.
A = [("D5", 3), ("E5", 1), ("F#5", 2), ("E5", 1), ("D5", 3), (None, 1), ("B4", 2), ("D5", 2), ("E5", 4), (None, 2)]
B = [("F#5", 3), ("A5", 1), ("B5", 2), ("A5", 1), ("F#5", 3), (None, 1), ("E5", 2), ("F#5", 2), ("D5", 4), (None, 2)]
C = [("A5", 2), ("B5", 2), ("D6", 4), ("B5", 2), ("A5", 2), ("F#5", 3), ("E5", 1), ("D5", 6), (None, 2)]
E = [("D5", 4), ("A4", 2), ("B4", 2), ("D5", 4), (None, 4)]
sections = [(14.0, A), (14.0 + 24 * BEAT, B), (14.0 + 48 * BEAT, A), (14.0 + 72 * BEAT, C), (14.0 + 96 * BEAT, B), (14.0 + 120 * BEAT, C)]
for start, phrase in sections:
    tcur = start
    for name, beats in phrase:
        ln = beats * BEAT
        if name and tcur < DUR - 8:
            add(melody, flute(D[name], ln * 1.04), tcur, 0.42, pan=0.12)
        tcur += ln
# closing phrase so the piece resolves on D
tcur = 112.0
for name, beats in E:
    if name:
        add(melody, flute(D[name], beats * BEAT * 1.05), tcur, 0.4, pan=0.12)
    tcur += beats * BEAT

# --- vina plucks: a slow ascending and descending figure underneath, 20 s onwards
fig = ["D4", "F#4", "A4", "B4", "A4", "F#4"]
tcur, i = 20.0, 0
while tcur < DUR - 10:
    add(melody, vina(D[fig[i % len(fig)]]), tcur, 0.17, pan=-0.3)
    tcur += BEAT * 1.0
    i += 1

# --- percussion: gentle frame drum on the one and three, soft shaker eighths, from 26 s to 118 s
dr, sh = frame_drum(), shaker()
tcur, beat_i = 26.0, 0
while tcur < 118.0:
    if beat_i % 4 == 0:
        add(perc, dr, tcur, 0.30)
    if beat_i % 4 == 2:
        add(perc, dr, tcur, 0.18)
    add(perc, sh, tcur, 0.05, pan=0.25)
    add(perc, sh, tcur + BEAT / 2, 0.03, pan=-0.25)
    tcur += BEAT
    beat_i += 1

# --- reverb on drone and melody (a soft hall)
def reverb(sig, seconds=2.8, wet=0.38):
    n = int(seconds * SR)
    t = np.arange(n) / SR
    out = np.zeros_like(sig)
    for ch in range(2):
        ir = rng.normal(size=n) * np.exp(-t / (seconds / 5.5))
        ir = sosfilt(butter(2, 5200, btype="low", fs=SR, output="sos"), ir)
        ir /= np.sqrt(np.sum(ir ** 2))
        out[:, ch] = fftconvolve(sig[:, ch], ir)[: len(sig)]
    return sig * (1 - wet) + out * wet * 1.6


mix = reverb(drone, 3.2, 0.30) + reverb(melody, 2.6, 0.42) + perc * 0.9

# --- arc: quiet start, fuller middle, soft end
arc = np.interp(t_all, [0, 8, 24, 100, 122, DUR], [0.45, 0.7, 1.0, 1.0, 0.85, 0.5])
mix *= arc[:, None]
fade = np.minimum(1, t_all / 2.5) * np.minimum(1, (DUR - t_all) / 7.0)
mix *= fade[:, None]
mix = np.tanh(mix * 0.9)
mix *= 0.89 / np.max(np.abs(mix))

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "music-v2.wav")
wavfile.write(out, SR, (mix * 32767).astype(np.int16))
print("wrote", out, f"{DUR:.0f}s")
