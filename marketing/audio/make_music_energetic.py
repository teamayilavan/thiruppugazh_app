"""Energetic alternative to make_music.py: same D Mohanam colours, but 108 bpm with a kick, claps, hats,
a plucked bass, a vina arpeggio, a flute lead and risers. Synthesized, no samples, no licence needed.

    python make_music_energetic.py      # writes music-v2-energetic.wav next to this file
"""
import os
import numpy as np
from scipy.signal import fftconvolve, butter, sosfilt
from scipy.io import wavfile

SR = 48000
DUR = 134.0
BPM = 108
BEAT = 60.0 / BPM
BAR = 4 * BEAT
rng = np.random.default_rng(11)
N = int(SR * DUR)
t_all = np.arange(N) / SR

F = {"D2": 73.42, "A2": 110.00, "B2": 123.47, "D3": 146.83, "A3": 220.00, "E4": 329.63, "D4": 293.66,
     "F#4": 369.99, "A4": 440.00, "B4": 493.88, "D5": 587.33, "E5": 659.25, "F#5": 739.99, "A5": 880.00,
     "B5": 987.77, "D6": 1174.66, "E6": 1318.51, "F#3": 185.00, "E3": 164.81}


def env(n, a, r):
    e = np.ones(n)
    na, nr = min(n, int(a * SR)), min(n, int(r * SR))
    if na:
        e[:na] = np.linspace(0, 1, na) ** 1.5
    if nr:
        e[-nr:] *= np.linspace(1, 0, nr) ** 1.5
    return e


def add(buf, sig, start_s, gain=1.0, pan=0.0):
    i = int(start_s * SR)
    if i >= buf.shape[0] or i < 0:
        return
    j = min(buf.shape[0], i + len(sig))
    s = sig[: j - i] * gain
    buf[i:j, 0] += s * (1 - max(0, pan))
    buf[i:j, 1] += s * (1 + min(0, pan))


def bp(lo, hi, x):
    return sosfilt(butter(2, [lo, hi], btype="band", fs=SR, output="sos"), x)


def kick():
    n = int(0.45 * SR)
    t = np.arange(n) / SR
    f = 48 + 120 * np.exp(-t / 0.035)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t / 0.16)
    s += 0.3 * bp(1500, 5000, rng.normal(size=n)) * np.exp(-t / 0.006)
    return s


def clap():
    n = int(0.3 * SR)
    t = np.arange(n) / SR
    s = bp(900, 3500, rng.normal(size=n))
    bursts = np.exp(-t / 0.09) + 0.8 * np.exp(-np.clip(t - 0.012, 0, None) / 0.03) * (t > 0.012) + 0.6 * np.exp(-np.clip(t - 0.024, 0, None) / 0.03) * (t > 0.024)
    return s * bursts * 0.7


def hat(open_=False):
    n = int((0.22 if open_ else 0.05) * SR)
    t = np.arange(n) / SR
    s = sosfilt(butter(2, 6500, btype="high", fs=SR, output="sos"), rng.normal(size=n))
    return s * np.exp(-t / (0.08 if open_ else 0.015))


def bass(freq, length):
    n = int(length * SR)
    t = np.arange(n) / SR
    saw = 2 * ((freq * t) % 1) - 1
    s = sosfilt(butter(2, 420, btype="low", fs=SR, output="sos"), saw) * 1.2 + np.sin(2 * np.pi * freq * t)
    return s * np.exp(-t / 0.35) * np.minimum(1, t / 0.004) * 0.6


def pluck(freq, length=0.9, bright=1.0):
    n = int(length * SR)
    t = np.arange(n) / SR
    s = (np.sin(2 * np.pi * freq * t) + 0.5 * bright * np.sin(2 * np.pi * 2 * freq * t) * np.exp(-t / 0.2)
         + 0.25 * bright * np.sin(2 * np.pi * 3 * freq * t) * np.exp(-t / 0.1))
    return s * np.exp(-t / 0.28) * np.minimum(1, t / 0.003)


def flute(freq, length, vib=0.005):
    n = int(length * SR)
    t = np.arange(n) / SR
    ve = np.minimum(1, t / 0.3) * vib
    ph = 2 * np.pi * np.cumsum(freq * (1 + ve * np.sin(2 * np.pi * 5.4 * t))) / SR
    tone = np.sin(ph) + 0.3 * np.sin(2 * ph) + 0.12 * np.sin(3 * ph)
    breath = bp(freq * 1.2, freq * 4, rng.normal(size=n)) * 0.07
    return (tone + breath) * env(n, 0.04, 0.12) / 1.6


def pad(freqs, length):
    n = int(length * SR)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f in freqs:
        for det in (-0.004, 0.0, 0.004):
            out += np.sin(2 * np.pi * f * (1 + det) * t + rng.uniform(0, 6.28))
    return out * env(n, 0.8, 0.8) / (3 * len(freqs))


def riser(length):
    n = int(length * SR)
    t = np.arange(n) / SR
    x = rng.normal(size=n)
    out = np.zeros(n)
    k = 24
    for i in range(k):  # a swept band built from slices
        a, b = int(i * n / k), int((i + 1) * n / k)
        lo = 300 + 6000 * (i / k) ** 2
        out[a:b] = bp(lo, lo * 1.8, x[a:b])
    return out * (t / length) ** 2


def crash():
    n = int(2.0 * SR)
    t = np.arange(n) / SR
    return sosfilt(butter(2, 4000, btype="high", fs=SR, output="sos"), rng.normal(size=n)) * np.exp(-t / 0.7)


drums = np.zeros((N, 2))
bassb = np.zeros((N, 2))
mel = np.zeros((N, 2))
bed = np.zeros((N, 2))

DROP = 4 * BAR        # the beat comes in after four bars
END_DRUMS = 52 * BAR  # drums stop here; the last bars resolve softly

# --- bed: soft drone (Sa and Pa) and pad, always present
tcur = 0.0
while tcur < DUR - 4:
    add(bed, pad([F["D3"], F["A3"], F["E4"]] if int(tcur / (4 * BAR)) % 2 == 0 else [F["B2"] * 2, F["F#3"] * 2, F["D4"]], 4 * BAR + 1), tcur, 0.7)
    tcur += 4 * BAR

# --- drums
kk, cl, hh, ho = kick(), clap(), hat(), hat(True)
bars = int(END_DRUMS / BAR)
for b in range(int(DROP / BAR), bars):
    t0 = b * BAR
    for beat in range(4):
        tb = t0 + beat * BEAT
        add(drums, kk, tb, 0.85)
        if beat in (1, 3):
            add(drums, cl, tb, 0.42)
        add(drums, hh, tb + BEAT / 2, 0.20)
        add(drums, hh, tb + BEAT / 4, 0.08, pan=0.3)
        add(drums, hh, tb + 3 * BEAT / 4, 0.10, pan=-0.3)
    add(drums, ho, t0 + 3.5 * BEAT, 0.16)
# light intro pulse before the drop
for b in range(int(2 * BAR / BAR), int(DROP / BAR)):
    for beat in range(4):
        add(drums, hh, b * BAR + beat * BEAT, 0.12)

# --- risers and crashes at section changes
sections = [int(DROP / BAR), 16, 28, 40]
for sbar in sections:
    t0 = sbar * BAR
    add(drums, riser(2 * BAR), t0 - 2 * BAR, 0.20)
    add(drums, crash(), t0, 0.35)

# --- bass: eighth-note pattern in D Mohanam, from the drop
pattern = ["D2", None, "D2", "A2", None, "D2", "B2", "A2"]
for b in range(int(DROP / BAR), bars):
    for i, nm in enumerate(pattern):
        if nm:
            add(bassb, bass(F[nm], BEAT / 2 * 1.6), b * BAR + i * BEAT / 2, 0.55)

# --- vina arpeggio in sixteenths-ish, from bar 8
arp = ["D4", "F#4", "A4", "B4", "D5", "B4", "A4", "F#4"]
for b in range(8, bars):
    for i in range(8):
        add(mel, pluck(F[arp[i]]), b * BAR + i * BEAT / 2, 0.20 if b < 28 else 0.26, pan=-0.3 if i % 2 else 0.3)

# --- flute lead (beats): phrases that move
A = [("D5", 1.5), ("E5", 0.5), ("F#5", 1), ("A5", 1), ("F#5", 1), ("E5", 1), ("D5", 2), ("E5", 1), ("F#5", 1), ("D5", 2), (None, 2)]
B = [("A5", 1.5), ("B5", 0.5), ("D6", 2), ("B5", 1), ("A5", 1), ("F#5", 1.5), ("E5", 0.5), ("D5", 2), (None, 2)]
C = [("D6", 1), ("B5", 1), ("A5", 1), ("F#5", 1), ("A5", 1), ("B5", 1), ("D6", 2), ("E6", 2), ("D6", 2), (None, 2)]
plan = [(16, A), (20, B), (24, A), (28, C), (32, B), (36, C), (40, A), (44, C), (48, B)]
for sbar, phrase in plan:
    tcur = sbar * BAR
    for name, beats in phrase:
        if name:
            add(mel, flute(F[name], beats * BEAT * 1.02), tcur, 0.36, pan=0.12)
        tcur += beats * BEAT
# a softer lead in the first drive section so the intro-to-drop has a hook
tcur = int(DROP / BAR) * BAR
for name, beats in [("D5", 2), ("F#5", 2), ("A5", 2), ("F#5", 2)] * 2:
    add(mel, flute(F[name], beats * BEAT * 1.02), tcur, 0.28, pan=0.12)
    tcur += beats * BEAT
# closing: a held D that resolves the piece
add(mel, flute(F["D5"], 4 * BAR), END_DRUMS, 0.38)
add(mel, flute(F["A4"], 4 * BAR), END_DRUMS, 0.22)
add(bassb, bass(F["D2"], 4.5), END_DRUMS, 0.7)


def reverb(sig, seconds, wet):
    n = int(seconds * SR)
    t = np.arange(n) / SR
    out = np.zeros_like(sig)
    for ch in range(2):
        ir = rng.normal(size=n) * np.exp(-t / (seconds / 5.5))
        ir = sosfilt(butter(2, 6000, btype="low", fs=SR, output="sos"), ir)
        ir /= np.sqrt(np.sum(ir ** 2))
        out[:, ch] = fftconvolve(sig[:, ch], ir)[: len(sig)]
    return sig * (1 - wet) + out * wet * 1.5


# sidechain-style pump: the bed and melody duck on every kick (from the drop)
pump = np.ones(N)
for b in range(int(DROP / BAR), bars):
    for beat in range(4):
        i = int((b * BAR + beat * BEAT) * SR)
        m = min(N - i, int(0.28 * SR))
        pump[i : i + m] = np.minimum(pump[i : i + m], 0.55 + 0.45 * (np.arange(m) / m) ** 1.5)

mix = reverb(bed, 2.2, 0.3) * pump[:, None] * 0.8 + reverb(mel, 1.6, 0.28) * (0.8 + 0.2 * pump)[:, None] + bassb * 1.0 + drums * 1.0

arc = np.interp(t_all, [0, DROP * 0.7, DROP, 40 * BAR, END_DRUMS + 2 * BAR, DUR], [0.55, 0.65, 1.0, 1.0, 0.8, 0.5])
mix *= arc[:, None]
mix *= (np.minimum(1, t_all / 1.5) * np.minimum(1, (DUR - t_all) / 6.0))[:, None]
mix = np.tanh(mix * 0.85)
mix *= 0.89 / np.max(np.abs(mix))

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "music-v2-energetic.wav")
wavfile.write(out, SR, (mix * 32767).astype(np.int16))
print("wrote", out, f"{DUR:.0f}s at {BPM} bpm")
