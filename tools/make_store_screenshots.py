"""Build Play Store screenshots with marketing captions.

Reads raw captures from screenshot/phone and screenshot/tablet, keeps the phone
status bar (time, network, battery) so the shots look like real devices, trims
only the bottom navigation bar, and composites each capture onto a branded
canvas with a caption. Backdrops alternate between a light surface and the brand
purple so the screenshot set does not look repetitive.

Output:
  screenshot/store/phone/*.png   -> 1080 x 1920 (Play phone requirement)
  screenshot/store/tablet/*.png  -> 1920 x 1200 (7"/10" tablet, landscape)

Run: python tools/make_store_screenshots.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "screenshot"
OUT = SRC / "store"
FONT_DIR = ROOT / "assets" / "fonts"

# Palette shared with playstore_asset_generator.html
BRAND = (96, 44, 145)          # #602C91
BRAND_LIGHT = (157, 111, 203)  # #9D6FCB
BRAND_DARK = (70, 32, 106)     # #46206A
ACCENT = (249, 115, 22)        # #F97316
SURFACE = (245, 247, 251)      # #F5F7FB
TEXT_DARK = (30, 41, 59)       # #1E293B
TEXT_MUTED = (100, 116, 139)   # #64748B
WHITE = (255, 255, 255)

PHONE_SIZE = (1080, 1920)
TABLET_SIZE = (1920, 1200)

# Theme per screenshot: alternating light / brand keeps the row from looking flat.
# (source name, headline, subline, theme, accent)
PHONE_CAPTIONS = [
    ("dashboard", "Your test, one app", "Rules, signs and exams together", "light", (249, 115, 22)),
    ("practice_quiz", "Practise the real format", "Timed questions, instant answers", "brand", (74, 222, 128)),
    ("exam_simulation", "Sit a full mock exam", "Same format as test day", "light", (14, 165, 233)),
    ("results", "Know your score instantly", "See every answer you missed", "brand", (251, 191, 36)),
    ("progress&insight", "Watch yourself improve", "Pass rate, best score, weak areas", "light", (16, 185, 129)),
    ("certificates", "Finish with a certificate", "Proof you completed every topic", "brand", (255, 209, 102)),
    ("resources", "Study offline, anywhere", "Traffic rules and signs bundled", "light", (99, 102, 241)),
    ("refer&earn", "Refer & Earn", "Invite friends and study together", "brand", (244, 114, 182)),
]

# When a localised capture exists it replaces that slot's English source and
# caption. Play allows eight phone screenshots, so these swap, not add.
LOCALISED = {
    "resources": ("phone_fr", "learning", "Maîtrisez le code de la route", "Apprenez, pratiquez, réussissez votre examen"),
    "refer&earn": ("phone_rw", "language", "Hitamo ururimi rwawe", "Kinyarwanda, Français cyangwa English"),
}


TABLET_CAPTIONS = [
    ("dashboard", "Your test, one app", "Everything, built for the bigger screen", "light", (249, 115, 22)),
    ("practice_exam", "Practise the real format", "Timed questions, instant answers", "brand", (74, 222, 128)),
    ("progress", "Track your progress", "See how you improve over time", "light", (16, 185, 129)),
    ("language", "Choose your language", "English, French or Kinyarwanda", "brand", (244, 114, 182)),
]


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_DIR / name), size)


def trim_nav(img: Image.Image) -> Image.Image:
    """Drop only the system navigation bar; the status bar stays visible."""
    w, h = img.size
    px = img.convert("RGB").load()
    nav = 72
    left, top, right, bottom = 0, 0, w, h

    def dark_row(y: int) -> bool:
        samples = [px[x, y] for x in range(0, w, max(1, w // 60))]
        avg = sum(sum(c) for c in samples) / (len(samples) * 3)
        return avg < 90

    def dark_col(x: int) -> bool:
        samples = [px[x, y] for y in range(0, h, max(1, h // 60))]
        avg = sum(sum(c) for c in samples) / (len(samples) * 3)
        return avg < 90

    if h > w:
        bottom -= nav
        limit = h // 6
        while bottom - 1 > limit and dark_row(bottom - 1):
            bottom -= 1
    else:
        right -= nav
        limit = w // 6
        while right - 1 > limit and dark_col(right - 1):
            right -= 1
        # Also drop a pinned taskbar that spans the bottom of the screen.
        limit = h // 6
        while bottom - 1 > limit and dark_row(bottom - 1):
            bottom -= 1

    return img.crop((left, top, right, bottom))


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, img.size[0] - 1, img.size[1] - 1), radius=radius, fill=255
    )
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def backdrop(size: tuple[int, int], theme: str, accent: tuple[int, int, int]) -> Image.Image:
    """Solid light surface, or a diagonal brand gradient, tinted by the accent."""
    w, h = size
    if theme == "brand":
        base = Image.new("RGB", (2, h))
        for y in range(h):
            t = y / max(1, h - 1)
            base.putpixel(
                (0, y),
                tuple(round(BRAND[i] + (BRAND_DARK[i] - BRAND[i]) * t) for i in range(3)),
            )
            base.putpixel(
                (1, y),
                tuple(round(BRAND_LIGHT[i] + (BRAND_DARK[i] - BRAND_LIGHT[i]) * t) for i in range(3)),
            )
        return base.resize(size, Image.BILINEAR).convert("RGBA")

    canvas = Image.new("RGB", size, SURFACE)
    # Soft accent tint in the top corner keeps the light theme from looking grey.
    glow = Image.new("RGBA", size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        (-w // 2, -h // 3, w + w // 2, h // 2), fill=(*accent, 46)
    )
    canvas = canvas.convert("RGBA")
    canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(160)))
    return canvas


def draw_center(draw: ImageDraw.ImageDraw, text: str, y: int, f, fill, width: int) -> None:
    left, top, right, bottom = draw.textbbox((0, 0), text, font=f)
    draw.text(((width - (right - left)) / 2 - left, y), text, font=f, fill=fill)


def draw_accent_bar(canvas: Image.Image, y: int, width: int, color) -> None:
    draw = ImageDraw.Draw(canvas)
    bar_w, bar_h = 96, 8
    x = (width - bar_w) // 2
    draw.rounded_rectangle((x, y, x + bar_w, y + bar_h), radius=bar_h // 2, fill=color)


def compose(
    src: Path,
    out: Path,
    size: tuple[int, int],
    headline: str,
    subline: str,
    theme: str,
    accent: tuple[int, int, int],
    *,
    header: int,
    side: int,
    bottom_margin: int,
    radius: int,
    h1: int,
    h2: int,
) -> None:
    canvas = backdrop(size, theme, accent)
    draw = ImageDraw.Draw(canvas)
    W, H = size

    ink = WHITE if theme == "brand" else TEXT_DARK
    ink_soft = (255, 255, 255, 225) if theme == "brand" else TEXT_MUTED

    title_y = int(header * 0.24)
    draw_center(draw, headline, title_y, font("Poppins-Bold.ttf", h1), ink, W)
    sub_y = title_y + int(h1 * 1.26)
    draw_center(draw, subline, sub_y, font("Poppins-Regular.ttf", h2), ink_soft, W)
    draw_accent_bar(canvas, sub_y + int(h2 * 2.1), W, accent)

    shot = trim_nav(Image.open(src))
    avail_w = W - side * 2
    avail_h = H - header - bottom_margin
    # Keep the whole screen visible (no cropping): fit within the available
    # area for both orientations, centred horizontally/vertically.
    portrait = shot.height >= shot.width
    scale = min(avail_w / shot.width, avail_h / shot.height)
    shot = shot.resize((round(shot.width * scale), round(shot.height * scale)), Image.LANCZOS)
    shot = rounded(shot, radius)

    # Thin device bezel so the capture reads as a phone, not a pasted image.
    bezel = max(8, round(radius * 0.28))
    framed = Image.new("RGBA", (shot.width + bezel * 2, shot.height + bezel * 2), (0, 0, 0, 0))
    frame = Image.new("RGBA", framed.size, (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle(
        (0, 0, framed.size[0] - 1, framed.size[1] - 1),
        radius=radius + bezel,
        fill=(24, 22, 30, 255) if theme == "light" else (32, 20, 50, 255),
    )
    framed.alpha_composite(frame)
    framed.alpha_composite(shot, (bezel, bezel))

    x = (W - framed.width) // 2
    y = header + (avail_h - framed.height) // 2

    shadow = Image.new("RGBA", (framed.width + 100, framed.height + 100), (0, 0, 0, 0))
    shadow.paste(framed, (50, 50), framed)
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    strength = 0.42 if theme == "brand" else 0.22
    shadow.putalpha(shadow.getchannel("A").point(lambda a: int(a * strength)))
    canvas.alpha_composite(shadow, (x - 50, y - 50 + 18))
    canvas.alpha_composite(framed, (x, y))

    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(out, "PNG", optimize=True)
    print(f"{out.relative_to(ROOT)}  {W}x{H}  ({theme})")


def main() -> None:
    for idx, (name, headline, subline, theme, accent) in enumerate(PHONE_CAPTIONS, start=1):
        safe = name.replace("&", "and")
        src = SRC / "phone" / f"{name}.jpeg"
        if name in LOCALISED:
            folder, local_name, local_headline, local_subline = LOCALISED[name]
            localised = SRC / folder / f"{local_name}.jpeg"
            if localised.exists():
                src, headline, subline = localised, local_headline, local_subline
        compose(
            src,
            OUT / "phone" / f"{idx:02d}_{safe}.png",
            PHONE_SIZE,
            headline,
            subline,
            theme,
            accent,
            header=330,
            side=120,
            bottom_margin=90,
            radius=38,
            h1=60,
            h2=32,
        )
    for idx, (name, headline, subline, theme, accent) in enumerate(TABLET_CAPTIONS, start=1):
        safe = name.replace("&", "and")
        compose(
            SRC / "tablet" / f"{name}.jpeg",
            OUT / "tablet" / f"{idx:02d}_{safe}.png",
            TABLET_SIZE,
            headline,
            subline,
            theme,
            accent,
            header=210,
            side=230,
            bottom_margin=70,
            radius=26,
            h1=58,
            h2=30,
        )


if __name__ == "__main__":
    main()
