"""Capture the six tablet screenshots in landscape from a connected Android tablet.

The script finds a tablet-sized adb device, forces landscape, opens the app and
walks through the six screens by tapping labels found in the UI hierarchy. If a
label cannot be found it falls back to asking you to open that screen by hand,
then captures whatever is on screen.

Usage:
    python tools/capture_tablet_screenshots.py                 # auto-navigate
    python tools/capture_tablet_screenshots.py --manual        # you navigate
    python tools/capture_tablet_screenshots.py -s <serial>     # pick a device
    python tools/capture_tablet_screenshots.py --language fr   # switch app language first

Raw captures are written to screenshot/tablet/<name>.jpeg; run
tools/make_store_screenshots.py afterwards to build the captioned Play assets.
"""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "screenshot" / "tablet"
REMOTE = "/sdcard/codebuff_capture.png"
UI_DUMP = "/sdcard/codebuff_ui.xml"
PKG = "com.trafficrules.rwanda.app"

# (output name, labels to tap from the dashboard, seconds to settle)
SCREENS = [
    ("dasboard", [], 3.0),
    ("practice-quiz", ["Practices", "Practice", "Practice Exam"], 2.5),
    ("certificate", ["Profile", "My Certificates"], 2.5),
    ("refer&earn", ["Share App", "Refer", "Refer & Earn"], 2.5),
    ("resources", ["NEW GAZETTE", "Gazette", "Resources"], 2.5),
    ("whatsapp", ["WhatsApp Group", "WhatsApp", "Study Groups"], 2.5),
]


def adb(*args: str, serial: str | None = None, check: bool = True) -> str:
    cmd = ["adb"] + (["-s", serial] if serial else []) + list(args)
    result = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if check and result.returncode != 0:
        raise RuntimeError(f"{' '.join(cmd)} failed: {result.stderr.strip() or result.stdout.strip()}")
    return result.stdout


def devices() -> list[str]:
    out = adb("devices")
    return [line.split()[0] for line in out.splitlines()[1:] if line.strip().endswith("device")]


def foreground(serial: str) -> str | None:
    """Package name of the activity currently on screen, or None."""
    out = adb("shell", "dumpsys", "window", serial=serial, check=False)
    for line in out.splitlines():
        if "mCurrentFocus" in line:
            match = re.search(r"u0 ([\w.]+)/", line)
            if match:
                return match.group(1)
    return None


def screen_size(serial: str) -> tuple[int, int]:
    match = re.search(r"(\d+)x(\d+)", adb("shell", "wm", "size", serial=serial))
    if not match:
        raise RuntimeError("could not read device screen size")
    return int(match.group(1)), int(match.group(2))


def pick_tablet(explicit: str | None, force: bool = False) -> str:
    if explicit:
        return explicit

    candidates = devices()
    if not candidates:
        sys.exit("No Android device connected. Connect the tablet and enable USB debugging.")
    for serial in candidates:
        w, h = screen_size(serial)
        if min(w, h) >= 1000:  # tablets report >= 1200x1600 px
            return serial
    if force and candidates:
        return candidates[0]
    sys.exit(
        "No tablet-sized device found (smallest side must be >= 1000 px). "
        "Connected: " + ", ".join(candidates)
    )


def force_landscape(serial: str) -> None:
    adb("shell", "settings", "put", "system", "accelerometer_rotation", "0", serial=serial)
    adb("shell", "settings", "put", "system", "user_rotation", "1", serial=serial)
    time.sleep(1.5)


def launch(serial: str, language: str | None) -> None:
    adb("shell", "am", "force-stop", PKG, serial=serial)
    adb("shell", "am", "start", "-W", "-n", f"{PKG}/.MainActivity", serial=serial, check=False)
    for _ in range(10):
        time.sleep(1.5)
        if foreground(serial) == PKG:
            break
    else:
        sys.exit(
            f"{PKG} is not on screen after launching. Check that it is installed "
            "and that its ABI matches the device (adb logcat | grep FlutterLoader)."
        )
    if language:
        # The dashboard language button opens the in-app language selector.
        tap_label(serial, ["LANGUAGE", "Language", "Indimi"], required=False)
        time.sleep(1.5)
        tap_label(serial, [language], required=False)
        time.sleep(1.5)


def ui_nodes(serial: str) -> list[ET.Element]:
    for _ in range(3):
        adb("shell", "uiautomator", "dump", UI_DUMP, serial=serial, check=False)
        adb("pull", UI_DUMP, str(ROOT / "build" / "ui.xml"), serial=serial, check=False)
        path = ROOT / "build" / "ui.xml"
        if path.exists():
            try:
                return list(ET.parse(path).getroot().iter("node"))
            except ET.ParseError:
                pass
        time.sleep(1.0)
    return []


def tap_label(serial: str, labels: list[str], required: bool = True) -> bool:
    nodes = ui_nodes(serial)
    for label in labels:
        for node in nodes:
            text = (node.get("text") or "") + (node.get("content-desc") or "")
            if label.lower() in text.lower():
                bounds = re.findall(r"\d+", node.get("bounds", ""))
                if len(bounds) == 4:
                    x = (int(bounds[0]) + int(bounds[2])) // 2
                    y = (int(bounds[1]) + int(bounds[3])) // 2
                    adb("shell", "input", "tap", str(x), str(y), serial=serial)
                    return True
    if required:
        print(f"  ! could not find {labels}")
    return False


def capture(serial: str, name: str) -> None:
    adb("shell", "screencap", REMOTE, serial=serial)
    local_png = ROOT / "build" / f"{name}.png"
    adb("pull", REMOTE, str(local_png), serial=serial)
    OUT.mkdir(parents=True, exist_ok=True)
    Image.open(local_png).convert("RGB").save(OUT / f"{name}.jpeg", "JPEG", quality=95)
    print(f"  saved screenshot/tablet/{name}.jpeg")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-s", "--serial", help="adb serial of the tablet")
    parser.add_argument("--manual", action="store_true", help="navigate by hand, capture on Enter")
    parser.add_argument("--language", help="tap this language name in the selector first")
    parser.add_argument(
        "--force",
        action="store_true",
        help="use the connected device even if it is not tablet-sized (e.g. 800x1280 panels)",
    )
    args = parser.parse_args()

    serial = pick_tablet(args.serial, args.force)
    w, h = screen_size(serial)
    print(f"Using {serial} ({w}x{h})")
    force_landscape(serial)
    launch(serial, args.language)

    for name, labels, settle in SCREENS:
        print(f"-> {name}")
        if not args.manual and labels:
            if name == "certificate":
                tap_label(serial, ["Profile"], required=False)
                time.sleep(1.2)
                tap_label(serial, ["My Certificates", "Certificates"], required=False)
            else:
                if not tap_label(serial, labels, required=False):
                    print("   (label not found, capture will use the current screen)")
        if args.manual:
            input(f"   open the {name} screen, then press Enter...")
        time.sleep(settle)
        if (current := foreground(serial)) != PKG:
            print(f"   ! skipping, {current or 'another app'} is on screen instead of {PKG}")
            continue
        capture(serial, name)

    print("\nDone. Build the captioned assets with: python tools/make_store_screenshots.py")


if __name__ == "__main__":
    main()
