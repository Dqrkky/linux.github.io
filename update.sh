#!/bin/bash
# === Dynamic sudo detection ===
if [[ $EUID -eq 0 ]]; then
    SUDO=""
    echo "[INFO] Running as root."
elif command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
    echo "[INFO] sudo detected. Using sudo."
else
    SUDO=""
    echo "[WARNING] sudo not found. Running without sudo."
fi

$SUDO apt-get update
$SUDO apt-get upgrade -y
$SUDO apt-get full-upgrade -y
