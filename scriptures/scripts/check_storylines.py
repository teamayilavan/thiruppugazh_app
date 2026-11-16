"""Check the storyline files and keep storylines/CHECKLIST.md in step with them.

Rules (storylines/README.md): total of the scene durations is at most 165 seconds,
7 to 9 scenes, English only (no Tamil characters), the required sections present.
A story is ticked in the checklist only when its file exists and passes these checks.

Run from the repo root:  python -I -X utf8 scriptures/scripts/check_storylines.py
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "storylines")
MAX_SECONDS = 165
SECTIONS = [
    "## One-line story",
    "## What the story rests on",
    "## Characters",
    "## The storyline",
    "## The Thiruppugazh connection",
    "## Production notes",
]
SCENE = re.compile(r"^### (\d+)\. .*\((\d+) sec\)\s*$", re.M)
TAMIL = re.compile("[஀-௿]")


def check(path):
    text = open(path, encoding="utf-8").read()
    problems = []
    scenes = SCENE.findall(text)
    total = sum(int(s) for _, s in scenes)
    if not 7 <= len(scenes) <= 9:
        problems.append(f"{len(scenes)} scenes (need 7 to 9)")
    if total > MAX_SECONDS:
        problems.append(f"{total} sec (max {MAX_SECONDS})")
    if TAMIL.search(text):
        problems.append("contains Tamil text")
    for h in SECTIONS:
        if h not in text:
            problems.append(f"missing section: {h}")
    nums = [int(n) for n, _ in scenes]
    if nums != list(range(1, len(nums) + 1)):
        problems.append("scene numbers are not 1..n")
    return total, len(scenes), problems


def main():
    ok = {}
    bad = 0
    for d in sorted(os.listdir(ROOT)):
        sub = os.path.join(ROOT, d)
        if not os.path.isdir(sub):
            continue
        for f in sorted(os.listdir(sub)):
            if not f.endswith(".md"):
                continue
            slug = f[:-3]
            total, n, problems = check(os.path.join(sub, f))
            if problems:
                bad += 1
                print(f"FAIL {d}/{slug}: " + "; ".join(problems))
            else:
                ok[slug] = (total, n)
    # Update the checklist ticks and the progress line.
    cl = os.path.join(ROOT, "CHECKLIST.md")
    lines = open(cl, encoding="utf-8").read().split("\n")
    out = []
    total_items = 0
    done = 0
    for line in lines:
        m = re.match(r"^- \[[ x~]\] `([^`]+)`: (.*)$", line)
        if m:
            total_items += 1
            slug, title = m.groups()
            title = re.sub(r"( \(\d+ scenes, \d+:\d\d\))+$", "", title)
            if slug in ok:
                done += 1
                t, n = ok[slug]
                line = f"- [x] `{slug}`: {title} ({n} scenes, {t // 60}:{t % 60:02d})"
            else:
                line = f"- [ ] `{slug}`: {title}"
        out.append(line)
    for i, line in enumerate(out):
        if line.startswith("Progress:"):
            out[i] = f"Progress: **{done} of {total_items}** written and passing `scripts/check_storylines.py`."
    open(cl, "w", encoding="utf-8", newline="\n").write("\n".join(out))
    print(f"{done} of {total_items} pass; {bad} fail")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
