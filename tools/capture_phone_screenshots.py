"""Capture the two localised phone screenshots (French resources, Kinyarwanda refer).

Run this with the phone connected and unlocked. It switches the in-app language,
opens the matching screen and writes:

    screenshot/phone_fr/resources.jpeg
    screenshot/phone_rw/refer&earn.jpeg

tools/make_store_screenshots.py picks those files up automatically and swaps
them into slots 07 and 08 with French and Kinyarwanda captions.

Usage:
    python tools/capture_phone_screenshots.py
    python tools/capture_phone_screenshots.py -s <serial>
    python tools/capture_phone_screenshots.py --keep-language   # do not restore English
"""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from capture_tablet_screenshots import adb, devices, foreground, screen_size, tap_label  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
REMOTE = "/sdcard/codebuff_phone.png"
PKG = "com.trafficrules.rwanda.app"

# (language label candidates, language button labels, screen labels, output)
JOBS = [
    (
        ["Français", "French"],
        ["LANGUAGE", "Language", "Indimi"],
        ["NEW GAZETTE", "Gazette", "Resources"],
        ROOT / "screenshot" / "phone_fr" / "resources.jpeg",
    ),
    (
        ["Kinyarwanda", "Ikinyarwanda"],
        ["LANGUAGE", "Language", "Indimi"],
        ["Share App", "Refer", "Refer & Earn"],
        ROOT / "screenshot" / "phone_rw" / "refer&earn.jpeg",
    ),
]


def pick_phone(explicit: str | None) -> str:
    if explicit:
        return explicit
    found = devices()
    if not found:
        sys.exit("No Android device connected. Plug the phone in, unlock it, then rerun.")
    return found[0]


def launch(serial: str) -> None:
    adb("shell", "am", "force-stop", PKG, serial=serial)
    adb("shell", "am", "start", "-W", "-n", f"{PKG}/.MainActivity", serial=serial, check=False)
    for _ in range(10):
        time.sleep(1.5)
        if foreground(serial) == PKG:
            return
    sys.exit(
        f"{PKG} did not reach the foreground. If it crashes with 'libflutter.so is "
        "32-bit instead of 64-bit', install an arm64 build first."
    )


def back_to_dashboard(serial: str) -> None:
    for _ in range(4):
        if tap_label(serial, ["Practices", "Progress"], required=False):
            return
        adb("shell", "input", "keyevent", "KEYCODE_BACK", serial=serial)
        time.sleep(1.0)


def set_language(serial: str, language_labels: list[str], button_labels: list[str]) -> bool:
    if not tap_label(serial, button_labels, required=False):
        return False
    time.sleep(1.5)
    changed = tap_label(serial, language_labels, required=False)
    time.sleep(1.5)
    back_to_dashboard(serial)
    return changed


def capture(serial: str, out: Path) -> None:
    adb("shell", "screencap", REMOTE, serial=serial)
    local = ROOT / "build" / f"{out.parent.name}_{out.stem.replace('&', 'and')}.png"
    local.parent.mkdir(parents=True, exist_ok=True)
    adb("pull", REMOTE, str(local), serial=serial)
    if foreground(serial) != PKG:
        print(f"  ! skipped {out.relative_to(ROOT)}, the app is not on screen")
        return
    out.parent.mkdir(parents=True, exist_ok=True)
    Image.open(local).convert("RGB").save(out, "JPEG", quality=95)
    print(f"  saved {out.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-s", "--serial", help="adb serial of the phone")
    parser.add_argument("--keep-language", action="store_true", help="do not switch back to English")
    args = parser.parse_args()

    serial = pick_phone(args.serial)
    w, h = screen_size(serial)
    adb("shell", "settings", "put", "system", "accelerometer_rotation", "0", serial=serial)
    adb("shell", "settings", "put", "system", "user_rotation", "0", serial=serial)
    print(f"Using {serial} ({w}x{h})")
    launch(serial)

    for language_labels, button_labels, screen_labels, out in JOBS:
        print(f"-> {out.relative_to(ROOT)}")
        if not set_language(serial, language_labels, button_labels):
            print("   ! language selector not found, capturing the current language")
        if not tap_label(serial, screen_labels, required=False):
            print("   ! screen tile not found, capturing the current screen")
        time.sleep(2.5)
        capture(serial, out)
        back_to_dashboard(serial)

    if not args.keep_language:
        set_language(serial, ["English"], ["LANGUAGE", "Language", "Indimi"])
    print("\nRebuild the captioned set with: python tools/make_store_screenshots.py")


if __name__ == "__main__":
    main()
