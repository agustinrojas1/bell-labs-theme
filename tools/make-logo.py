"""Draw the striped globe used as the fastfetch logo.

Each character row holds two pixel rows (half blocks), so pixels stay square
in a 1:2 terminal cell. Stripes thicken toward the bottom like an engraved
globe: thin lines with wide gaps on top, heavy bands with hairline gaps below.

usage: python3 tools/make-logo.py [rows]   (default 20 rows = 40 columns)
"""
import sys

rows = int(sys.argv[1]) if len(sys.argv) > 1 else 20
D = rows * 2
R = D / 2

# One glyph per character row: █ both pixels, ▀ top only, ▄ bottom only.
third = rows // 3
pattern = ("▀ " * third)[:rows - 2 * third]
pattern += ("█ " * third)[:third]
pattern += ("█▀" * third)[:rows - len(pattern)]
pattern = pattern.ljust(rows)[:rows]

ink = []
for g in pattern:
    ink += [g in "█▀", g in "█▄"]


def on(x, y):
    dx, dy = x + 0.5 - R, y + 0.5 - R
    return ink[y] and dx * dx + dy * dy <= R * R


out = []
for cy in range(0, D, 2):
    line = ""
    for x in range(D):
        top, bot = on(x, cy), on(x, cy + 1)
        line += "█" if top and bot else "▀" if top else "▄" if bot else " "
    out.append("$1" + line.rstrip())
print("\n".join(out))
