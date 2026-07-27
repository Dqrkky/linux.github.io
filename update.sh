#!/bin/bash

# === CONFIGURATION ===
LOGFILE="apt-cleanup.log"
CURRENT_KERNEL=$(uname -r)
HOSTNAME=$(uname -n)

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

# Load webhook URL (secure option)
if [[ -f .webhook_url ]]; then
    WEBHOOK_URL=$(< .webhook_url)
    echo "[INFO] Webhook loaded."
else
    WEBHOOK_URL=""
    echo "[WARNING] No webhook configured."
fi

# === FUNCTIONS ===
send_webhook() {
    if [[ -z "$WEBHOOK_URL" ]]; then
        echo "[WARNING] Webhook disabled."
        return
    fi
    local message
    message=$(jq -Rs . <<< "$1")
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"[RAUC]: $HOSTNAME\",\"content\":$message}" \
        "$WEBHOOK_URL"
}

log() {
    printf "%b\n" "$1" | tee -a "$LOGFILE"
}

# === START SCRIPT ===
: > "$LOGFILE"
log "🚀 Starting APT full cleanup"
log "🔍 Running kernel: $CURRENT_KERNEL"
log "https://www.ubuntuupdates.org/package/core/noble/main/updates/linux-modules-$CURRENT_KERNEL"
log "https://www.ubuntuupdates.org/bugs?package_name=linux-modules-$CURRENT_KERNEL"

log "🔄 Updating package lists..."
$SUDO apt update | tee -a "$LOGFILE"

log "⬆️ Performing full-upgrade..."
$SUDO apt full-upgrade -y | tee -a "$LOGFILE"

log "🧹 Autoremoving unused packages..."
$SUDO apt autoremove -y | tee -a "$LOGFILE"

log "🧽 Autocleaning package cache..."
$SUDO apt autoclean | tee -a "$LOGFILE"

log "🧼 Purging orphaned config files..."
orphans=$(dpkg -l | awk '/^rc/ { print $2 }')
if [ -n "$orphans" ]; then
    echo "$orphans" | xargs $SUDO apt purge -y | tee -a "$LOGFILE"
    log "✅ Orphaned configs purged."
else
    log "✅ No orphaned config files found."
fi

# Kernel check and optional reboot
NEWEST_KERNEL=$(dpkg --list 'linux-image-*' | awk '/^ii/ {print $2}' | grep -E '^linux-image-[0-9]' | sed 's/linux-image-//' | sort -V | tail -n1)
log "🆕 Installed kernel: $NEWEST_KERNEL"
log "https://www.ubuntuupdates.org/package/core/noble/main/updates/linux-modules-$NEWEST_KERNEL"
log "https://www.ubuntuupdates.org/bugs?package_name=linux-modules-$NEWEST_KERNEL"

if [ "$CURRENT_KERNEL" != "$NEWEST_KERNEL" ]; then
    log "🔁 Kernel updated — scheduling reboot in 1 minute..."
    $SUDO shutdown -r +1 "Rebooting after kernel upgrade"
else
    log "✅ Kernel not changed — no reboot needed."
fi

log "🎉 APT cleanup finished successfully."
send_webhook "$(cat "$LOGFILE")"