#!/bin/bash

# === CONFIGURATION ===
LOGFILE="apt-cleanup.log"
CURRENT_KERNEL=$(uname -r)
HOSTNAME=$(uname -n)

# Load webhook URL (secure option)
if [[ -f .webhook_url ]]; then
    WEBHOOK_URL=$(< .webhook_url)
else
    WEBHOOK_URL="https://example.com"
fi

# === FUNCTIONS ===
send_webhook() {
    local message
    message=$(jq -Rs . <<< "$1")   # escape safely
    curl -s -X POST -H "Content-Type: application/json" \
        -d "{\"username\": \"[RAUC]: $HOSTNAME\", \"content\": $message}" \
        "$WEBHOOK_URL" > /dev/null
}

log() {
    echo "$1" | tee -a "$LOGFILE"
}

# === START SCRIPT ===
: > "$LOGFILE"
log "🚀 Starting APT full cleanup"
log "🔍 Running kernel: $CURRENT_KERNEL"

log "🔄 Updating package lists..."
sudo apt update | tee -a "$LOGFILE"

log "⬆️ Performing full-upgrade..."
sudo apt full-upgrade -y | tee -a "$LOGFILE"

log "🧹 Autoremoving unused packages..."
sudo apt autoremove -y | tee -a "$LOGFILE"

log "🧽 Autocleaning package cache..."
sudo apt autoclean | tee -a "$LOGFILE"

log "🧼 Purging orphaned config files..."
orphans=$(dpkg -l | awk '/^rc/ { print $2 }')
if [ -n "$orphans" ]; then
    echo "$orphans" | xargs sudo apt purge -y | tee -a "$LOGFILE"
    log "✅ Orphaned configs purged."
else
    log "✅ No orphaned config files found."
fi

# Kernel check and optional reboot
NEWEST_KERNEL=$(dpkg --list | awk '/^ii\s+linux-image-[0-9]/ {print $2}' | sort -V | tail -n1 | sed 's/linux-image-//')
log "🆕 Installed kernel: $NEWEST_KERNEL"

if [ "$CURRENT_KERNEL" != "$NEWEST_KERNEL" ]; then
    log "🔁 Kernel updated — scheduling reboot in 1 minute..."
    sudo shutdown -r +1 "Rebooting after kernel upgrade"
else
    log "✅ Kernel not changed — no reboot needed."
fi

log "🎉 APT cleanup finished successfully."
send_webhook "$(cat "$LOGFILE")"
