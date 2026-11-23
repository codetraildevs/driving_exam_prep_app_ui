from PIL import Image, ImageDraw, ImageFont, ImageFilter
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from make_store_screenshots import trim_nav, FONT_DIR

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "screenshot" / "store" / "featured_graphic.png"
W, H = 1024, 500

canvas = Image.new("RGB", (W, H), (106, 57, 164))
# diagonal gradient
for y in range(H):
    for x in range(W):
        t = (x / W + y / H) / 2
        r = int(106 + (139 - 106) * t)
        g = int(57 + (92 - 57) * t)
        b = int(164 + (246 - 164) * t)
        canvas.putpixel((x, y), (r, g, b))

# soft glow
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
gd.ellipse((W - 320, -80, W + 80, 420), fill=(251, 191, 36, 70))
glow = glow.filter(ImageFilter.GaussianBlur(60))
canvas = Image.alpha_composite(canvas.convert("RGBA"), glow).convert("RGB")

# phone mockup on right
raw = Image.open(ROOT / "screenshot" / "phone" / "dashboard.jpeg")
raw = trim_nav(raw)
# portrait trim already; scale to fit height
avail_h = H - 60
scale = avail_h / raw.height
fw = int(raw.width * scale)
fh = int(raw.height * scale)
framed = raw.resize((fw, fh), Image.LANCZOS)
# rounded mask
mask = Image.new("L", (fw, fh), 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, fw - 1, fh - 1), radius=36, fill=255)
phone = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
phone.paste(framed.convert("RGBA"), (0, 0), mask)
# shadow
shadow = Image.new("RGBA", (fw + 40, fh + 40), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.rounded_rectangle((20, 20, fw + 19, fh + 19), radius=40, fill=(0, 0, 0, 110))
shadow = shadow.filter(ImageFilter.GaussianBlur(18))
px = W - fw - 40
py = (H - fh) // 2
canvas.paste(shadow.convert("RGB"), (px - 20, py - 20), shadow)
canvas.paste(phone, (px, py), phone)

# text on left
draw = ImageDraw.Draw(canvas)
def f(name, size):
    return ImageFont.truetype(str(FONT_DIR / name), size)
title = f("Poppins-Bold.ttf", 46)
sub = f("Poppins-SemiBold.ttf", 24)
small = f("Poppins-Regular.ttf", 16)
draw.text((56, 90), "Rwanda Traffic Rule", font=title, fill=(255, 255, 255))
draw.text((56, 150), "Learn. Practice. Pass.", font=sub, fill=(254, 243, 199))
# accent bar
draw.rounded_rectangle((56, 195, 56 + 120, 201), radius=3, fill=(251, 191, 36))

# feature pills
pills = ["Offline study", "Mock exams", "Certificates", "Progress tracking"]
y = 230
for p in pills:
    tw = draw.textlength(p, font=small)
    draw.rounded_rectangle((56, y, 56 + tw + 28, y + 30), radius=15, fill=(255, 255, 255))
    draw.text((56 + 14, y + 6), p, font=small, fill=(90, 40, 140))
    y += 42

# footer line
draw.text((56, H - 52), "Free study companion for Rwanda's driving test", font=small, fill=(230, 230, 250))

OUT.parent.mkdir(parents=True, exist_ok=True)
canvas.save(OUT, "PNG")
print("saved", OUT, canvas.size)
