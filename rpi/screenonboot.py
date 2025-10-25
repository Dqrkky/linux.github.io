#!/usr/bin/env python3
import os
import subprocess
import time
import shutil
import sys

URL = "https://dqrkky.pages.dev"   # 👈 change this to your website
DISPLAY = ":0"

def run(cmd):
    """Run a shell command safely."""
    print(f"[CMD] {' '.join(cmd)}")
    subprocess.run(cmd, check=False)

def ensure_installed(packages):
    """Ensure required packages are installed."""
    print("[INFO] Checking dependencies...")
    missing = [pkg for pkg in packages if shutil.which(pkg) is None]
    if missing:
        print(f"[INFO] Installing: {' '.join(missing)}")
        run(["sudo", "apt", "update"])
        run(["sudo", "apt", "install", "-y"] + missing)
    else:
        print("[OK] All dependencies already installed.")

def start_x_server():
    """Start a minimal X server if not running."""
    if not os.path.exists("/tmp/.X11-unix/X0"):
        print("[INFO] Starting X server on HDMI...")
        subprocess.Popen(
            ["startx"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        time.sleep(5)
    else:
        print("[OK] X server already running.")

def launch_browser():
    """Launch Chromium in kiosk mode."""
    os.environ["DISPLAY"] = DISPLAY
    print(f"[INFO] Launching Chromium in kiosk mode for {URL}")
    run([
        "chromium-browser",
        "--noerrdialogs",
        "--disable-infobars",
        "--disable-translate",
        "--no-first-run",
        "--kiosk",
        "--incognito",
        URL
    ])

def main():
    if os.geteuid() != 0:
        print("⚠️  Please run this script with sudo for first-time setup.")
    ensure_installed(["chromium-browser", "xserver-xorg", "xinit", "x11-xserver-utils"])
    start_x_server()
    launch_browser()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[EXIT] User interrupted.")
        sys.exit(0)
