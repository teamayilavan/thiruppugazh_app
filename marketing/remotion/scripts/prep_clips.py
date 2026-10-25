"""Turn raw emulator recordings into compact, constant-30fps clips for Remotion.

screenrecord writes frames only when the screen changes, so idle stretches show up as gaps in the
timestamps. We keep each burst of activity (plus a short hold after it so results can be read) and
drop the idle gaps. Output: public/clips/<name>.mp4 (720x1600, 30 fps) and public/clips/clips.json
(durations in seconds). Needs ffmpeg/ffprobe on PATH or in the WinGet location.
"""
import glob, json, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.normpath(os.path.join(HERE, "..", "..", "recordings", "raw"))
OUT = os.path.normpath(os.path.join(HERE, "..", "public", "clips"))
IDLE_GAP = 0.7      # a gap longer than this between frames is idle
LEAD = 0.15         # seconds kept before a burst
HOLD = 0.8          # seconds kept after a burst so the result can be read
SKIP = {"test_home"}


def tool(name):
    hits = glob.glob(os.path.join(os.environ.get("LOCALAPPDATA", ""), "Microsoft", "WinGet", "Packages",
                                  "Gyan.FFmpeg*", "ffmpeg-*", "bin", name + ".exe"))
    return hits[0] if hits else name


FFMPEG, FFPROBE = tool("ffmpeg"), tool("ffprobe")


def frame_times(path):
    out = subprocess.run([FFPROBE, "-v", "error", "-select_streams", "v:0", "-show_entries", "frame=pts_time",
                          "-of", "csv=p=0", path], capture_output=True, text=True, check=True).stdout
    return [float(x) for x in out.split() if x.strip()]


def windows(times):
    wins, start, prev = [], times[0], times[0]
    for t in times[1:]:
        if t - prev > IDLE_GAP:
            wins.append([max(0, start - LEAD), prev + HOLD])
            start = t
        prev = t
    wins.append([max(0, start - LEAD), prev + HOLD])
    merged = [wins[0]]
    for a, b in wins[1:]:
        if a <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], b)
        else:
            merged.append([a, b])
    return merged


def main():
    os.makedirs(OUT, exist_ok=True)
    meta = {}
    for path in sorted(glob.glob(os.path.join(RAW, "*.mp4"))):
        name = os.path.splitext(os.path.basename(path))[0]
        if name in SKIP:
            continue
        times = frame_times(path)
        wins = windows(times)
        sel = "+".join(f"between(t,{a:.3f},{b:.3f})" for a, b in wins)
        dur = sum(b - a for a, b in wins)
        dest = os.path.join(OUT, name + ".mp4")
        subprocess.run([FFMPEG, "-v", "error", "-y", "-i", path, "-an",
                        "-vf", f"fps=30,select='{sel}',setpts=N/(30*TB),scale=720:1600:flags=lanczos",
                        "-c:v", "libx264", "-preset", "slow", "-crf", "18", "-pix_fmt", "yuv420p", "-r", "30", dest],
                       check=True)
        meta[name] = {"raw_seconds": round(times[-1], 2), "active_seconds": round(dur, 2), "windows": len(wins)}
        print(f"{name}: raw {times[-1]:.1f}s -> active {dur:.1f}s ({len(wins)} windows)")
    with open(os.path.join(OUT, "clips.json"), "w") as f:
        json.dump(meta, f, indent=2)


if __name__ == "__main__":
    sys.exit(main())
