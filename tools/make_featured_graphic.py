from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "screenshot" / "store"
W, H = 1024, 500
FONT_DIR = ROOT / "assets" / "fonts"

sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_store_screenshots import trim_nav


def build_variant(src_path: Path, out_name: str, brand_text: str, headline: str,
                  subline: str, pills: list[str]) -> None:
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))

    # Vivid diagonal brand gradient.
    for y in range(H):
        for x in range(W):
            t = (x / W + y / H) / 2
            r = int(96 + (168 - 96) * t)
            g = int(44 + (85 - 44) * t)
            b = int(145 + (247 - 145) * t)
            canvas.putpixel((x, y), (r, g, b, 255))

    # Soft glows.
    glow1 = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow1).ellipse((W - 300, -100, W + 100, 360), fill=(251, 191, 36, 60))
    canvas.alpha_composite(glow1.filter(ImageFilter.GaussianBlur(70)))

    glow2 = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow2).ellipse((-120, H - 220, 220, H + 80), fill=(56, 189, 248, 40))
    canvas.alpha_composite(glow2.filter(ImageFilter.GaussianBlur(80)))

    # Phone mockup on the right.
    raw = trim_nav(Image.open(src_path))
    avail_h = H - 70
    scale = avail_h / raw.height
    fw = int(raw.width * scale)
    fh = int(raw.height * scale)
    framed = raw.resize((fw, fh), Image.LANCZOS)

    mask = Image.new("L", (fw, fh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, fw - 1, fh - 1), radius=30, fill=255)
    phone = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    phone.paste(framed.convert("RGBA"), (0, 0), mask)

    bezel = 10
    bezeled = Image.new("RGBA", (fw + bezel * 2, fh + bezel * 2), (0, 0, 0, 0))
    ImageDraw.Draw(bezeled).rounded_rectangle(
        (0, 0, bezeled.width - 1, bezeled.height - 1), radius=34, fill=(24, 22, 30, 255)
    )
    bezeled.alpha_composite(phone, (bezel, bezel))

    shadow = Image.new("RGBA", (bezeled.width + 40, bezeled.height + 40), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle((20, 20, bezeled.width + 19, bezeled.height + 19), radius=40, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))

    px = W - bezeled.width - 46
    py = (H - bezeled.height) // 2
    canvas.alpha_composite(shadow, (px - 20, py - 20))
    canvas.alpha_composite(bezeled, (px, py))

    # Text on the left.
    draw = ImageDraw.Draw(canvas)

    def font(name, size):
        return ImageFont.truetype(str(FONT_DIR / name), size)

    brand_font = font("Poppins-SemiBold.ttf", 18)
    title_font = font("Poppins-Bold.ttf", 40)
    sub_font = font("Poppins-SemiBold.ttf", 20)
    pill_font = font("Poppins-SemiBold.ttf", 18)

    WHITE = (255, 255, 255)
    SOFT = (245, 240, 255)
    ACCENT = (251, 191, 36)

    LEFT = 56
    draw.text((LEFT, 92), brand_text, font=brand_font, fill=SOFT)
    draw.rounded_rectangle((LEFT, 124, LEFT + 72, 130), radius=3, fill=ACCENT)

    # Wrap headline if needed.
    def wrap(text, font_obj, max_w):
        words = text.split()
        lines = []
        cur = ""
        for w_ in words:
            test = (cur + " " + w_).strip()
            if draw.textlength(test, font=font_obj) <= max_w:
                cur = test
            else:
                if cur:
                    lines.append(cur)
                cur = w_
        if cur:
            lines.append(cur)
        return lines

    max_text_w = px - LEFT - 24
    lines = wrap(headline, title_font, max_text_w)
    y = 148
    for line in lines:
        draw.text((LEFT, y), line, font=title_font, fill=WHITE)
        y += 46

    draw.text((LEFT, y + 4), subline, font=sub_font, fill=SOFT)
    y += 46

    pill_y = y + 12
    x = LEFT
    for p in pills:
        tw = draw.textlength(p, font=pill_font)
        pw = tw + 26
        if x + pw > px - 12:
            break
        draw.rounded_rectangle((x, pill_y, x + pw, pill_y + 30), radius=15, fill=(255, 255, 255, 235))
        draw.text((x + 13, pill_y + 6), p, font=pill_font, fill=(90, 40, 140))
        x += pw + 12

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / out_name
    canvas.convert("RGB").save(out_path, "PNG", optimize=True)
    print("saved", out_path, canvas.size)


if __name__ == "__main__":
    build_variant(
        ROOT / "screenshot" / "phone" / "dashboard.jpeg",
        "featured_graphic.png",
        "RWANDA TRAFFIC RULE",
        "Prepare for your driving test",
        "Practice questions, mock exams, progress tracking",
        ["Offline study", "Mock exams", "Progress tracking"],
    )
    build_variant(
        ROOT / "screenshot" / "phone_fr" / "learning.jpeg",
        "featured_graphic_fr.png",
        "CODE DE LA ROUTE RWANDA",
        "Préparez votre examen de conduite",
        "Questions, examens blancs, suivi des progrès",
        ["Étude hors ligne", "Examens blancs", "Suivi des progrès"],
    )
