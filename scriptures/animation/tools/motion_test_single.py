"""Pipeline smoke test: a 6-second motion test from ONE flat image plus the gold frame.

This is deliberately crude (no depth layers yet): slow push-in, glow pulse behind the child,
twinkling stars, shimmering water, rising sparks. It proves the render and encode chain;
the real films use separate layers in Blender.

    python -I -X utf8 scriptures/animation/tools/motion_test_single.py <scene.png> <frame_keyed.png> <out.mp4>
"""
import subprocess
import sys

import numpy as np
from PIL import Image

W, H, FPS, SECS = 1920, 1080, 30, 6
BW, BH = 2304, 1296            # working size (1.2x output) so the push-in stays sharp


def lowres_noise(h, w, cell, rng):
    small = rng.random((h // cell + 1, w // cell + 1)).astype(np.float32)
    return np.kron(small, np.ones((cell, cell), np.float32))[:h, :w]


def main():
    scene_p, frame_p, out_p = sys.argv[1:4]
    base = np.asarray(Image.open(scene_p).convert("RGB").resize((BW, BH), Image.LANCZOS)).astype(np.float32)
    frame = Image.open(frame_p).convert("RGBA").resize((W, H), Image.LANCZOS)
    rng = np.random.default_rng(7)

    yy, xx = np.mgrid[0:BH, 0:BW].astype(np.float32)
    # water: below the shore, away from the lotus and the side reeds
    lotus = np.clip(1.0 - (((xx - 0.50 * BW) / (0.31 * BW)) ** 2 + ((yy - 0.60 * BH) / (0.30 * BH)) ** 2), 0, 1) ** 0.5
    lotus = np.clip(lotus * 3.0, 0, 1)
    sides = np.clip((np.minimum(xx, BW - xx) - 0.10 * BW) / (0.05 * BW), 0, 1)
    below = np.clip((yy - 0.47 * BH) / (0.04 * BH), 0, 1)
    water = (1.0 - lotus) * sides * below
    # stars: sky band, not the moon or the clouds' rows
    moon = np.clip((((xx - 0.735 * BW) ** 2 + (yy - 0.14 * BH) ** 2) ** 0.5 - 0.075 * BW) / 20.0, 0, 1)
    sky = np.clip((0.30 * BH - yy) / (0.03 * BH), 0, 1) * moon
    phase = lowres_noise(BH, BW, 5, rng) * 2 * np.pi
    glow_r = ((xx - 0.50 * BW) ** 2 + (yy - 0.43 * BH) ** 2) / (2 * (0.20 * BH) ** 2)
    glow = np.exp(-glow_r)[..., None] * np.array([255, 165, 55], np.float32) / 255.0
    # sparks
    n = 44
    sx = rng.uniform(0.40, 0.60, n) * BW
    sy0 = rng.uniform(0.40, 0.58, n) * BH
    sv = rng.uniform(0.035, 0.08, n) * BH      # px per second
    sp = rng.uniform(0, 1, n)
    sr = rng.uniform(2.5, 5.0, n)

    ff = subprocess.Popen(
        ["ffmpeg", "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}",
         "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "slow", "-crf", "15",
         "-pix_fmt", "yuv420p", "-movflags", "+faststart", out_p],
        stdin=subprocess.PIPE)

    rows = np.arange(BH)
    cols = np.arange(BW)
    for f in range(FPS * SECS):
        t = f / FPS
        img = base.copy()
        # shimmering water: per-row horizontal wobble, blended by the water mask
        s = (2.6 * np.sin(2 * np.pi * (rows / 46.0 + t * 0.55)) + 1.4 * np.sin(2 * np.pi * (rows / 17.0 - t * 0.9))).astype(np.int32)
        idx = (cols[None, :] - s[:, None]) % BW
        shifted = img[rows[:, None], idx]
        img = img * (1 - water[..., None]) + shifted * water[..., None]
        # glow pulse (screen-style add)
        pulse = 0.10 + 0.07 * np.sin(2 * np.pi * t / 3.0)
        img = 255.0 - (255.0 - img) * (1.0 - glow * pulse)
        # twinkling stars
        tw = 1.0 + 0.22 * np.sin(2 * np.pi * (t * 0.9) + phase) * sky
        img = np.clip(img * tw[..., None], 0, 255)
        # rising sparks
        for i in range(n):
            life = (t * 0.25 + sp[i]) % 1.0
            cy = sy0[i] - sv[i] * life * 14
            cx = sx[i] + 18 * np.sin(2 * np.pi * (life * 1.5 + sp[i]))
            a = np.sin(np.pi * life) ** 1.5
            r = int(sr[i] * 3)
            y0, y1, x0, x1 = int(cy) - r, int(cy) + r + 1, int(cx) - r, int(cx) + r + 1
            if y0 < 0 or x0 < 0 or y1 > BH or x1 > BW:
                continue
            gy, gx = np.mgrid[y0:y1, x0:x1]
            g = np.exp(-(((gy - cy) ** 2 + (gx - cx) ** 2) / (2 * sr[i] ** 2))) * a
            img[y0:y1, x0:x1] += g[..., None] * np.array([255, 200, 90], np.float32) * 0.9
        img = np.clip(img, 0, 255)
        # slow push-in toward the child
        k = f / (FPS * SECS - 1)
        z = 1.0 + 0.055 * (k * k * (3 - 2 * k))
        cw, ch = BW / z / 1.2, BH / z / 1.2        # output area at z=1 is BW/1.2
        cx0, cy0 = 0.5 * BW, 0.53 * BH
        l, tp = cx0 - cw / 2, cy0 - ch / 2
        l = min(max(l, 0), BW - cw); tp = min(max(tp, 0), BH - ch)
        im = Image.fromarray(img.astype(np.uint8)).resize((W, H), Image.BICUBIC, box=(l, tp, l + cw, tp + ch))
        out = im.convert("RGBA")
        out.alpha_composite(frame)
        ff.stdin.write(np.asarray(out.convert("RGB")).tobytes())
    ff.stdin.close()
    ff.wait()
    print("wrote", out_p)


if __name__ == "__main__":
    main()
