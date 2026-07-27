#!/bin/bash
LOGFILE="apt-update.log"

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

log() {
    printf "%b\n" "$1" | tee -a "$LOGFILE"
}

log "🔄 Updating package lists..."
$SUDO apt-get update

log "⬆️ Performing full-upgrade..."
$SUDO apt-get full-upgrade -y

log "🧹 Autoremoving unused packages..."
$SUDO apt autoremove -y

log "🧽 Autocleaning package cache..."
$SUDO apt autoclean
