#!/bin/bash

CONFIG="/boot/firmware/config.txt"
BACKUP="$CONFIG.backup.$(date +%Y%m%d_%H%M%S)"

# Ensure the config file exists
if [ ! -f "$CONFIG" ]; then
    echo "Error: $CONFIG not found. Are you sure you're on Ubuntu for Raspberry Pi?"
    exit 1
fi

echo "Backing up config to $BACKUP"
sudo cp "$CONFIG" "$BACKUP"

# Check if overlay already exists
if grep -q "^dtoverlay=rpi-tv" "$CONFIG"; then
    echo "dtoverlay=rpi-tv is already present in config.txt"
else
    echo "Adding dtoverlay=rpi-tv to config.txt..."
    if grep -q "^dtparam=i2c_arm=on" "$CONFIG"; then
        # Insert after dtparam=i2c_arm=on
        sudo sed -i "/^dtparam=i2c_arm=on/a dtoverlay=rpi-tv" "$CONFIG"
    else
        # Add both dtparam and dtoverlay at the end
        echo "dtparam=i2c_arm=on not found — adding both entries at the end"
        {
            echo ""
            echo "dtparam=i2c_arm=on"
            echo "dtoverlay=rpi-tv"
        } | sudo tee -a "$CONFIG" > /dev/null
    fi
    echo "Overlay added successfully."
    echo "Please reboot your Raspberry Pi:"
    echo "    sudo reboot"
fi
