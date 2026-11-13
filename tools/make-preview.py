"""Compose a theme preview from real fastfetch output.

usage: fastfetch --pipe false | python3 tools/make-preview.py <palette.toml> <wallpaper> <out.png>

Renders the ANSI output (truecolor, bold, cursor columns) with GoMono Nerd
Font inside a rio-style window over the wallpaper, under an acme tag-line bar.
"""
import glob
import re
import sys
import tomllib

from PIL import Image, ImageDraw, ImageFont

with open(sys.argv[1], "rb") as f:
    P = tomllib.load(f)
wallpaper, out = sys.argv[2], sys.argv[3]
W, H = 2560, 1440
SIZE, LH = 26, 34


def find_font(style):
    hits = glob.glob(f"/usr/share/fonts/**/GoMonoNerdFont-{style}.ttf", recursive=True)
    return ImageFont.truetype(hits[0], SIZE)


reg, bold = find_font("Regular"), find_font("Bold")
cw = reg.getlength("M")
ansi = [P[k] for k in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")]
ansi += [P["bright_" + k] for k in ("black", "red", "green", "yellow", "blue", "magenta", "cyan", "white")]


def parse(line):
    """Yield (column, char, colour, bold) for one line of ANSI output."""
    col, fg, b = 0, P["foreground"], False
    for tok in re.split(r"(\x1b\[[0-9;]*[mG])", line):
        if tok.startswith("\x1b["):
            body, kind = tok[2:-1], tok[-1]
            if kind == "G":
                col = int(body) - 1
                continue
            codes = [int(c) for c in body.split(";") if c] or [0]
            i = 0
            while i < len(codes):
                c = codes[i]
                if c == 0:
                    fg, b = P["foreground"], False
                elif c == 1:
                    b = True
                elif c == 22:
                    b = False
                elif c == 39:
                    fg = P["foreground"]
                elif 30 <= c <= 37:
                    fg = ansi[c - 30]
                elif 90 <= c <= 97:
                    fg = ansi[c - 82]
                elif c == 38 and codes[i + 1:i + 2] == [2]:
                    fg = "#%02X%02X%02X" % tuple(codes[i + 2:i + 5])
                    i += 4
                i += 1
            continue
        for ch in tok:
            yield col, ch, fg, b
            col += 1


lines = re.sub(r"\x1b\[\?[0-9]+[hl]", "", sys.stdin.read()).splitlines()
import os, socket
me = f"{os.environ.get('USER', '')}@{socket.gethostname()}"
lines = [l.replace(me, "ken@research") for l in lines]
while lines and not lines[-1].strip():
    lines.pop()
cols = max((max((c for c, *_ in parse(l)), default=0) for l in lines), default=80) + 2

img = Image.open(wallpaper).convert("RGB").resize((W, H))
d = ImageDraw.Draw(img)

# acme tag line as the bar
d.rectangle([0, 0, W, 40], fill=P["background_alt"])
d.line([0, 40, W, 40], fill=P["border_active"], width=3)
x = 18
for i in range(1, 5):
    if i == 1:
        d.rectangle([x - 8, 0, x + cw + 8, 39], fill=P["selection_alt"])
    d.text((x, 6), str(i), font=reg, fill=P["foreground"])
    x += cw + 26
status = "vol 70%   net wired   Mon 13 Nov 22:10"
d.text((W - 18 - reg.getlength(status), 6), status, font=reg, fill=P["foreground"])

# rio-style framed window
ww, wh = int(cols * cw) + 60, len(lines) * LH + 60
wx, wy = (W - ww) // 2, (H - wh) // 2 + 20
d.rectangle([wx - 5, wy - 5, wx + ww + 5, wy + wh + 5], fill=P["border_active"])
d.rectangle([wx, wy, wx + ww, wy + wh], fill=P["background"])

y = wy + 30
for line in lines:
    for col, ch, fg, b in parse(line):
        x = wx + 30 + col * cw
        if ch in "█▀▄":  # half blocks drawn as pixels
            if ch in "█▀":
                d.rectangle([x, y, x + cw, y + LH / 2], fill=fg)
            if ch in "█▄":
                d.rectangle([x, y + LH / 2, x + cw, y + LH], fill=fg)
        elif ch != " ":
            d.text((x, y + 2), ch, font=bold if b else reg, fill=fg)
    y += LH

img.save(out, optimize=True)
print("wrote", out)
