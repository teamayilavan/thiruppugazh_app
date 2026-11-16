"""Cut the chroma-green opening out of a frame image and test it over a scene.

    python -I -X utf8 scriptures/animation/tools/key_frame.py <frame.png> <scene.png> <out_dir>

Writes <out_dir>/frame_keyed.png (RGBA, transparent opening, green spill removed)
and <out_dir>/frame_over_scene.png (1920x1080 composite) and prints how clean the key is.
"""
import os
import sys

import numpy as np
from PIL import Image


def key_green(img):
    a = np.asarray(img.convert("RGB")).astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    dom = g - np.maximum(r, b)              # how much greener than the other channels
    alpha = 1.0 - np.clip((dom - 40.0) / 90.0, 0.0, 1.0)   # soft edge between 40 and 130
    # remove green spill on the edge pixels that stay partly visible
    g2 = np.where(alpha < 1.0, np.minimum(g, np.maximum(r, b) + 8.0), g)
    out = np.dstack([r, g2, b, alpha * 255.0]).clip(0, 255).astype(np.uint8)
    return Image.fromarray(out, "RGBA"), alpha


def main():
    frame_p, scene_p, out_dir = sys.argv[1:4]
    os.makedirs(out_dir, exist_ok=True)
    frame = Image.open(frame_p)
    keyed, alpha = key_green(frame)
    keyed.save(os.path.join(out_dir, "frame_keyed.png"))

    hole = float((alpha < 0.05).mean()) * 100
    partial = float(((alpha >= 0.05) & (alpha < 0.95)).mean()) * 100
    print(f"frame {frame.size}: opening (transparent) {hole:.1f}% of the image, soft-edge pixels {partial:.2f}%")
    # isolated transparent specks inside the gold = keying leaks
    leaks = int(((alpha < 0.05)).sum())
    print(f"transparent pixels: {leaks}")

    W, H = 1920, 1080
    scene = Image.open(scene_p).convert("RGB").resize((W, H), Image.LANCZOS)
    fr = keyed.resize((W, H), Image.LANCZOS)
    comp = scene.convert("RGBA")
    comp.alpha_composite(fr)
    comp.convert("RGB").save(os.path.join(out_dir, "frame_over_scene.png"))
    print("wrote", os.path.join(out_dir, "frame_keyed.png"), "and frame_over_scene.png")


if __name__ == "__main__":
    main()
