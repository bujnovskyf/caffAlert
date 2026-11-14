"""Generate CaffAlert launcher icons and the Play Store icon from the brand master.

Run from the repository root:  python3 docs/play-store/graphics/source/make_icons.py
Needs only Pillow. Outputs:
  android/app/src/main/res/mipmap-*/ic_launcher_foreground.png   (adaptive foreground, 108 dp)
  android/app/src/main/res/drawable/ic_launcher_background.xml   (flat cream)
  android/app/src/main/res/drawable/ic_launcher_monochrome.xml   (themed icon, vector)
  android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml
  docs/play-store/graphics/icon-512.png
The legacy mipmap-*/ic_launcher.png files (API 24-25) are left untouched.
"""
import math
import os
from PIL import Image

MASTER = "assets/brand/caffalert-icon-master.png"
RES = "android/app/src/main/res"
BG = (248, 237, 221)  # master background, #F8EDDD
CENTER = (624, 596)   # centre of the minimal circle enclosing cup, saucer and steam
CONTENT_R = 406       # radius of that circle in master pixels
FG_CONTENT_DP = 30    # content radius inside the 108 dp canvas (safe zone is 33 dp)
MONO_SCALE = 0.9      # monochrome glyph slightly smaller than the colour artwork


def color_to_alpha(px):
    """Separate a pixel from the flat background (GIMP colour-to-alpha)."""
    a = 0.0
    for c, b in zip(px, BG):
        if c > b:
            a = max(a, (c - b) / (255 - b))
        elif c < b:
            a = max(a, (b - c) / b)
    if a <= 0:
        return (0, 0, 0, 0)
    a = min(a, 1.0)
    rgb = tuple(max(0, min(255, round((c - b * (1 - a)) / a))) for c, b in zip(px, BG))
    return rgb + (round(a * 255),)


def foreground_master():
    src = Image.open(MASTER).convert("RGB")
    w, h = src.size
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    sp, op = src.load(), out.load()
    cx, cy = CENTER
    limit2 = (CONTENT_R + 30) ** 2
    for y in range(h):
        for x in range(w):
            p = sp[x, y]
            if sum(abs(c - b) for c, b in zip(p, BG)) <= 4:
                continue  # background noise / gentle gradient
            if (x - cx) ** 2 + (y - cy) ** 2 > limit2:
                continue
            op[x, y] = color_to_alpha(p)
    return out


def write_foregrounds(fg):
    canvas_px = round(CONTENT_R * 108 / FG_CONTENT_DP)
    canvas = Image.new("RGBA", (canvas_px, canvas_px), (0, 0, 0, 0))
    canvas.paste(fg, (canvas_px // 2 - CENTER[0], canvas_px // 2 - CENTER[1]))
    for name, scale in [("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3), ("xxxhdpi", 4)]:
        size = round(108 * scale)
        canvas.resize((size, size), Image.LANCZOS).save(
            f"{RES}/mipmap-{name}/ic_launcher_foreground.png", optimize=True)
    return canvas


def write_play_icon():
    src = Image.open(MASTER).convert("RGB")
    half = round(CONTENT_R / 0.37 / 2)  # content radius = 37 % of the icon width
    box = (CENTER[0] - half, CENTER[1] - half, CENTER[0] + half, CENTER[1] + half)
    icon = src.crop(box).resize((512, 512), Image.LANCZOS).convert("RGBA")
    icon.save("docs/play-store/graphics/icon-512.png", optimize=True)


# ---------- monochrome vector, authored in master pixel coordinates ----------

def f(v):
    return f"{v:.1f}".rstrip("0").rstrip(".")


def circle(cx, cy, r):
    return (f"M{f(cx - r)},{f(cy)} a{f(r)},{f(r)} 0 1,0 {f(2 * r)},0 "
            f"a{f(r)},{f(r)} 0 1,0 {f(-2 * r)},0 Z")


def pt(cx, cy, r, deg):
    a = math.radians(deg)
    return cx + r * math.cos(a), cy + r * math.sin(a)


def band(cx, cy, r_out, r_in, a0, a1):
    """Annular sector from angle a0 to a1 (degrees, clockwise on screen)."""
    large = 1 if (a1 - a0) % 360 > 180 else 0
    x0, y0 = pt(cx, cy, r_out, a0)
    x1, y1 = pt(cx, cy, r_out, a1)
    x2, y2 = pt(cx, cy, r_in, a1)
    x3, y3 = pt(cx, cy, r_in, a0)
    return (f"M{f(x0)},{f(y0)} A{f(r_out)},{f(r_out)} 0 {large},1 {f(x1)},{f(y1)} "
            f"L{f(x2)},{f(y2)} A{f(r_in)},{f(r_in)} 0 {large},0 {f(x3)},{f(y3)} Z")


def capsule(x0, y0, x1, y1, r):
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy)
    nx, ny = -dy / length * r, dx / length * r
    return (f"M{f(x0 + nx)},{f(y0 + ny)} L{f(x1 + nx)},{f(y1 + ny)} "
            f"A{f(r)},{f(r)} 0 0,0 {f(x1 - nx)},{f(y1 - ny)} "
            f"L{f(x0 - nx)},{f(y0 - ny)} A{f(r)},{f(r)} 0 0,0 {f(x0 + nx)},{f(y0 + ny)} Z")


def hub_and_hand(cx, cy, hub_r, tip, half_w):
    """Outline of the union of the hub circle and the clock hand (one hole)."""
    ang = math.atan2(tip[1] - cy, tip[0] - cx)
    nx, ny = -math.sin(ang), math.cos(ang)
    off = math.sqrt(hub_r ** 2 - half_w ** 2)
    ux, uy = math.cos(ang), math.sin(ang)
    a = (cx + ux * off + nx * half_w, cy + uy * off + ny * half_w)
    b = (cx + ux * off - nx * half_w, cy + uy * off - ny * half_w)
    ta = (tip[0] + nx * half_w, tip[1] + ny * half_w)
    tb = (tip[0] - nx * half_w, tip[1] - ny * half_w)
    return (f"M{f(a[0])},{f(a[1])} L{f(ta[0])},{f(ta[1])} "
            f"A{f(half_w)},{f(half_w)} 0 0,0 {f(tb[0])},{f(tb[1])} "
            f"L{f(b[0])},{f(b[1])} A{f(hub_r)},{f(hub_r)} 0 1,0 {f(a[0])},{f(a[1])} Z")


# Steam curls traced from the master: centre line from the base (in the coffee) to the tip,
# with the curl's width at each point.
STEAM_BIG = [((612, 410), 30), ((591, 377), 48), ((598, 343), 62),
             ((621, 310), 68), ((640, 287), 58), ((648, 262), 42), ((644, 233), 28),
             ((628, 208), 16), ((608, 195), 0)]
# The short curl sits a little further right than in the master so the two curls
# stay separate in the single-colour icon.
STEAM_SMALL = [((688, 404), 10), ((690, 386), 18), ((699, 368), 24),
               ((716, 350), 24), ((734, 332), 20), ((741, 312), 15), ((737, 292), 8),
               ((724, 276), 0)]
STEAM_GAP = 11  # transparent margin between the steam and whatever lies behind it


def catmull(points, steps):
    pts = [points[0]] + points + [points[-1]]
    out = []
    for i in range(1, len(pts) - 2):
        p0, p1, p2, p3 = pts[i - 1], pts[i], pts[i + 1], pts[i + 2]
        for j in range(steps):
            t = j / steps
            t2, t3 = t * t, t * t * t
            out.append(tuple(0.5 * (2 * b + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2
                                    + (-a + 3 * b - 3 * c + d) * t3)
                             for a, b, c, d in zip(p0, p1, p2, p3)))
    out.append(points[-1])
    return out


def curl(spec, steps=8):
    """Tapered curl outline: smooth centre line offset by half the width on each side."""
    centre = catmull([p for p, _ in spec], steps)
    widths = catmull([(w, 0) for _, w in spec], steps)
    left, right = [], []
    for i, ((x, y), (w, _)) in enumerate(zip(centre, widths)):
        (xa, ya), (xb, yb) = centre[max(0, i - 1)], centre[min(len(centre) - 1, i + 1)]
        dx, dy = xb - xa, yb - ya
        ln = math.hypot(dx, dy) or 1
        nx, ny = -dy / ln * w / 2, dx / ln * w / 2
        left.append((x + nx, y + ny))
        right.append((x - nx, y - ny))
    # Round the base with a half circle.
    (bx, by), bw = centre[0], widths[0][0] / 2
    (cx2, cy2) = centre[1]
    ang = math.atan2(cy2 - by, cx2 - bx)
    cap = [(bx + bw * math.cos(ang + math.pi / 2 + k * math.pi / 8),
            by + bw * math.sin(ang + math.pi / 2 + k * math.pi / 8)) for k in range(1, 8)]
    return left + list(reversed(right)) + cap


def curl_gap(spec):
    """The curl grown by STEAM_GAP on every side (same centre line, wider, longer tip)."""
    (tx, ty), (px, py) = spec[-1][0], spec[-2][0]
    ln = math.hypot(tx - px, ty - py)
    tip = (tx + (tx - px) / ln * STEAM_GAP, ty + (ty - py) / ln * STEAM_GAP)
    grown = [(p, w + 2 * STEAM_GAP) for p, w in spec[:-1]] + [(tip, 0)]
    return curl(grown)


def poly_path(poly, reverse=False):
    pts = list(reversed(poly)) if reverse else poly
    return "M" + " L".join(f"{f(x)},{f(y)}" for x, y in pts) + " Z"


def is_clockwise(poly):
    return sum(x0 * y1 - x1 * y0 for (x0, y0), (x1, y1) in zip(poly, poly[1:] + poly[:1])) > 0


def clip_without(poly):
    """Clip region = big square minus `poly` (opposite windings, non-zero rule)."""
    square = "M-200,-200 L1500,-200 L1500,1500 L-200,1500 Z"  # clockwise on screen
    return square + " " + poly_path(poly, reverse=is_clockwise(poly))


def mono_parts():
    cx, cy = 617, 628
    body = []
    # Saucer band, broken around the handle.
    body.append(("nonZero", band(cx, cy, 351, 304, 13, 347)))
    # Cup rim.
    body.append(("evenOdd", circle(cx, cy, 289) + " " + circle(cx, cy, 249)))
    # Handle.
    body.append(("nonZero", capsule(880, 629, 968, 629, 54)))
    # Coffee with the clock carved out of it.
    hx, hy = 620, 628
    holes = [
        capsule(620, 482, 620, 506, 13),   # 12
        capsule(620, 752, 620, 776, 13),   # 6
        capsule(450, 628, 474, 628, 13),   # 9
        capsule(768, 628, 792, 628, 13),   # 3
        hub_and_hand(hx, hy, 36, (736, 522), 15),
    ]
    body.append(("evenOdd", circle(cx, cy, 228) + " " + " ".join(holes)))
    body.append(("nonZero", circle(hx, hy, 15)))
    big, small = curl(STEAM_BIG), curl(STEAM_SMALL)
    return body, big, small


def write_monochrome():
    body, big, small = mono_parts()
    s = 108 / (CONTENT_R * 108 / FG_CONTENT_DP) * MONO_SCALE
    tx, ty = 54 - s * CENTER[0], 54 - s * CENTER[1]
    gap_big, gap_small = curl_gap(STEAM_BIG), curl_gap(STEAM_SMALL)

    def path(rule, d, ind):
        return [f'{ind}<path android:fillColor="#FFFFFFFF" android:fillType="{rule}"',
                f'{ind}    android:pathData="{d}" />']

    lines = [
        '<?xml version="1.0" encoding="utf-8"?>',
        '<!-- Themed (monochrome) launcher icon. Generated by',
        '     docs/play-store/graphics/source/make_icons.py; edit the script, not this file. -->',
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"',
        '    android:width="108dp"',
        '    android:height="108dp"',
        '    android:viewportWidth="108"',
        '    android:viewportHeight="108">',
        f'    <group android:translateX="{tx:.4f}" android:translateY="{ty:.4f}"'
        f' android:scaleX="{s:.6f}" android:scaleY="{s:.6f}">',
        '        <!-- Cup, saucer and clock, with a gap carved around both steam curls. -->',
        '        <group>',
        f'            <clip-path android:pathData="{clip_without(gap_small)}" />',
        '            <group>',
        f'                <clip-path android:pathData="{clip_without(gap_big)}" />',
    ]
    for rule, d in body:
        lines += path(rule, d, '                ')
    lines += [
        '            </group>',
        '        </group>',
        '        <!-- Tall steam curl, cut where the small curl passes in front of it. -->',
        '        <group>',
        f'            <clip-path android:pathData="{clip_without(gap_small)}" />',
    ]
    lines += path("nonZero", poly_path(big), '            ')
    lines += ['        </group>']
    lines += path("nonZero", poly_path(small), '        ')
    lines += ['    </group>', '</vector>', '']
    with open(f"{RES}/drawable/ic_launcher_monochrome.xml", "w") as fh:
        fh.write("\n".join(lines))


def write_static_xml():
    os.makedirs(f"{RES}/mipmap-anydpi-v26", exist_ok=True)
    with open(f"{RES}/mipmap-anydpi-v26/ic_launcher.xml", "w") as fh:
        fh.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@drawable/ic_launcher_background" />\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
            '    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />\n'
            '</adaptive-icon>\n')
    with open(f"{RES}/drawable/ic_launcher_background.xml", "w") as fh:
        fh.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<!-- Adaptive icon background: the cream of the brand master (#F8EDDD). -->\n'
            '<shape xmlns:android="http://schemas.android.com/apk/res/android"\n'
            '    android:shape="rectangle">\n'
            '    <solid android:color="#FFF8EDDD" />\n'
            '</shape>\n')


if __name__ == "__main__":
    import sys
    if "--mono-only" not in sys.argv:
        write_foregrounds(foreground_master())
        write_play_icon()
    write_static_xml()
    write_monochrome()
    print("done")
