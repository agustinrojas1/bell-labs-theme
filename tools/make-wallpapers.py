"""Render the Bell Labs wallpapers for one palette.

usage: python3 tools/make-wallpapers.py <palette.toml> <out-dir>
         [--size 3840x2160] [--user NAME] [--date TEXT] [--fonts DIR]
         [--only globe|rio|greenbar|telstar ...]

  1-globe.png     striped globe and BELL LABORATORIES on the page colour
  2-rio.png       rio's plain desktop
  3-greenbar.png  continuous-form printout with a job listing
  4-telstar.png   Telstar, the satellite Bell Labs built in 1962

--user sets the name printed on the green-bar job (default: $USER, upper-cased).
--date sets the timestamp the listing's `date` prints.
--fonts is a directory with Go-Mono.ttf and Go-Mono-Bold.ttf (or the GoMono
Nerd Font files). Without it, the usual Arch, NixOS and Go module locations
are searched. Drawing happens at 2x and is downsampled for clean edges.
"""
import argparse
import glob
import math
import os
import random
import sys
import tomllib

from PIL import Image, ImageChops, ImageDraw, ImageFont

ap = argparse.ArgumentParser(description="Render the Bell Labs wallpapers.")
ap.add_argument("palette")
ap.add_argument("out_dir")
ap.add_argument("--size", default="3840x2160")
ap.add_argument("--user", default=os.environ.get("USER", "dmr"))
ap.add_argument("--date", default="MON NOV 13 22:10:00 EST 1978")
ap.add_argument("--fonts")
ap.add_argument("--only", nargs="+", choices=["globe", "rio", "greenbar", "telstar"])
args = ap.parse_args()

with open(args.palette, "rb") as f:
    P = tomllib.load(f)
W, H = map(int, args.size.split("x"))
SS = 2
w, h = W * SS, H * SS
os.makedirs(args.out_dir, exist_ok=True)


def find_fonts():
    """Return (regular, bold) paths for Go Mono."""
    pairs = [("Go-Mono.ttf", "Go-Mono-Bold.ttf"), ("GoMonoNerdFont-Regular.ttf", "GoMonoNerdFont-Bold.ttf")]
    dirs = [args.fonts] if args.fonts else []
    dirs += glob.glob(os.path.expanduser("~/go/pkg/mod/golang.org/x/image@*/font/gofont/ttfs"))
    for root in ["/usr/share/fonts", os.path.expanduser("~/.local/share/fonts"),
                 os.path.expanduser("~/.nix-profile/share/fonts"), "/run/current-system/sw/share/X11/fonts"]:
        for reg, _ in pairs:
            dirs += [os.path.dirname(p) for p in glob.glob(f"{root}/**/{reg}", recursive=True)]
    for d in dirs:
        for reg, bold in pairs:
            if os.path.exists(os.path.join(d, reg)) and os.path.exists(os.path.join(d, bold)):
                return os.path.join(d, reg), os.path.join(d, bold)
    sys.exit("Go Mono not found: install ttf-go-nerd / pkgs.go-font, or pass --fonts DIR")


REGULAR, BOLD = find_fonts()


def font(size, bold=False):
    return ImageFont.truetype(BOLD if bold else REGULAR, size * SS)


def save(img, name):
    img.resize((W, H), Image.LANCZOS).save(os.path.join(args.out_dir, name), optimize=True)
    print("wrote", os.path.join(args.out_dir, name))


def tracked(draw, xy, text, fnt, fill, tracking):
    """Draw text with extra letter spacing, centred on xy."""
    widths = [draw.textlength(ch, font=fnt) for ch in text]
    x = xy[0] - (sum(widths) + tracking * (len(text) - 1)) / 2
    for ch, cw in zip(text, widths):
        draw.text((x, xy[1]), ch, font=fnt, fill=fill)
        x += cw + tracking


def sphere(size, ink):
    """Striped sphere: thin bands at the top, thickening toward the bottom."""
    n = 12
    weights = [0.16 + 0.56 * (i / (n - 1)) ** 1.2 for i in range(n)]
    pitch = size / n
    stripes = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(stripes)
    for i, wt in enumerate(weights):
        top = i * pitch + (pitch * (1 - wt)) / 2
        d.rectangle([0, top, size, top + pitch * wt], fill=255)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, size - 1, size - 1], fill=255)
    layer = Image.new("RGBA", (size, size), ink)
    layer.putalpha(ImageChops.multiply(stripes, mask))
    return layer


def globe():
    img = Image.new("RGBA", (w, h), P["background"])
    s = int(h * 0.36)
    img.alpha_composite(sphere(s, P["accent"]), ((w - s) // 2, int(h * 0.24)))
    d = ImageDraw.Draw(img)
    cy = int(h * 0.24) + s + int(h * 0.06)
    tracked(d, (w / 2, cy), "BELL LABORATORIES", font(int(H * 0.030), True), P["accent"], int(H * 0.012) * SS)
    tracked(d, (w / 2, cy + H * 0.055 * SS), "MURRAY HILL, NEW JERSEY", font(int(H * 0.014)),
            P["foreground_dim"], int(H * 0.008) * SS)
    return img.convert("RGB")


def rio():
    return Image.new("RGB", (w, h), P["desktop"])


def greenbar():
    """Continuous-form printout: bars, tractor-feed holes and a job listing."""
    img = Image.new("RGB", (w, h), P["printout_paper"])
    d = ImageDraw.Draw(img)
    line = int(H * 0.0222) * SS             # one printed line
    band = line * 3                          # bars are three lines tall
    margin = int(W * 0.045) * SS
    for y in range(0, h, band * 2):
        d.rectangle([margin, y, w - margin, y + band - 1], fill=P["printout_bar"])
    hole_r, hole_gap = int(H * 0.0075) * SS, int(H * 0.0235) * SS
    for y in range(hole_gap // 2, h, hole_gap):
        for x in (margin // 2, w - margin // 2):
            d.ellipse([x - hole_r, y - hole_r, x + hole_r, y + hole_r], fill=P["desktop"])
    for x in (margin, w - margin):
        for y in range(0, h, int(line * 0.6)):
            d.line([x, y, x, y + line * 0.3], fill=P["printout_rule"], width=SS * 2)

    user = args.user.upper()[:8]
    listing = [
        "",
        "   UNIX TIME-SHARING SYSTEM              BELL LABORATORIES              PAGE 0001",
        "",
        f"   JOB 0729   USER {user:<8}   QUEUE lp0   CLASS A   FORM GREENBAR-14   COPIES 1",
        "",
        "   $ cc -o hello hello.c",
        "   $ ./hello",
        "   hello, world",
        "   $ wc -l /etc/passwd",
        "        42 /etc/passwd",
        "   $ who | sort | uniq -c | sort -rn | sed 1q",
        f"         7 {args.user.lower()[:8]}",
        "   $ date",
        f"   {args.date}",
        "   $ echo $STATUS",
        "   ALL SYSTEMS NOMINAL",
        "",
        "   ***  END OF JOB 0729  ***   MAINTENANCE: CUSTOMER RESPONSIBILITY   ***",
    ]
    f = font(int(H * 0.0175))
    for i, text in enumerate(listing):
        d.text((margin + line, band * 2 + i * line + line * 0.15), text, font=f, fill=P["printout_ink"])
    return img


def telstar():
    """Sky (or star chart, on paper), an orbit and the faceted Telstar sphere."""
    img = Image.new("RGBA", (w, h), P["background"])
    d = ImageDraw.Draw(img)
    rng = random.Random(1962)
    stars = [P["foreground_dim"], P["foreground"], P["bright_black"]]
    if P.get("mode") != "dark":
        stars = [P["muted"], P["border_active"], P["foreground_dim"]]
    for _ in range(900 if P.get("mode") == "dark" else 600):
        x, y = rng.uniform(0, w), rng.uniform(0, h)
        r = rng.choice([1, 1, 1, 2, 2, 3]) * SS * 0.8
        d.ellipse([x - r, y - r, x + r, y + r], fill=rng.choice(stars))

    # orbit: a tilted ellipse drawn as a dashed polyline
    cx, cy, rx, ry, tilt = w * 0.5, h * 0.55, w * 0.42, h * 0.18, math.radians(-12)

    def on_orbit(t):
        x, y = rx * math.cos(t), ry * math.sin(t)
        return cx + x * math.cos(tilt) - y * math.sin(tilt), cy + x * math.sin(tilt) + y * math.cos(tilt)

    pts = [on_orbit(2 * math.pi * i / 720) for i in range(721)]
    for i in range(0, 720, 6):
        d.line(pts[i:i + 4], fill=P["border_active"], width=2 * SS)

    # the satellite, upper right on the orbit
    sx, sy = on_orbit(2 * math.pi * 0.86)
    R = h * 0.075
    hx, hy = sx, sy - R                      # helix antenna on top
    d.line([hx, hy, hx, hy - R * 0.55], fill=P["foreground_dim"], width=3 * SS)
    for k in range(7):
        yy = hy - R * 0.08 - k * R * 0.065
        d.ellipse([hx - R * 0.09, yy - R * 0.02, hx + R * 0.09, yy + R * 0.02], outline=P["foreground_dim"], width=2 * SS)
    body = Image.new("RGBA", (int(2 * R), int(2 * R)), (0, 0, 0, 0))
    bd = ImageDraw.Draw(body)
    bd.ellipse([0, 0, 2 * R - 1, 2 * R - 1], fill=P["background_alt"], outline=P["border_active"], width=3 * SS)
    for k in range(1, 9):                    # rows of solar cells
        yy = 2 * R * k / 9
        half = math.sqrt(max(R * R - (yy - R) ** 2, 0))
        bd.line([R - half, yy, R + half, yy], fill=P["border_active"], width=2 * SS)
    for k in range(-3, 4):
        xx = R + k * R / 3.4
        half = math.sqrt(max(R * R - (xx - R) ** 2, 0))
        bd.line([xx, R - half, xx, R + half], fill=P["border_active"], width=SS)
    for k in range(-5, 6):                   # equatorial ring of antenna ports
        xx = R + k * R / 6.2
        bd.rectangle([xx - R * 0.035, R - R * 0.06, xx + R * 0.035, R + R * 0.06], fill=P["accent"])
    img.alpha_composite(body, (int(sx - R), int(sy - R)))

    tracked(d, (w * 0.5, h * 0.84), "TELSTAR", font(int(H * 0.030), True), P["accent"], int(H * 0.014) * SS)
    tracked(d, (w * 0.5, h * 0.84 + H * 0.055 * SS), "BELL TELEPHONE LABORATORIES  ·  10 JULY 1962",
            font(int(H * 0.013)), P["foreground_dim"], int(H * 0.006) * SS)
    return img.convert("RGB")


wallpapers = {"globe": ("1-globe.png", globe), "rio": ("2-rio.png", rio),
              "greenbar": ("3-greenbar.png", greenbar), "telstar": ("4-telstar.png", telstar)}
for key in args.only or wallpapers:
    name, draw = wallpapers[key]
    save(draw(), name)
