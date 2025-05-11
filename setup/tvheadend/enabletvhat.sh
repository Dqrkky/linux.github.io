#!/bin/bash

CONFIG="/boot/firmware/config.txt"
BACKUP="$CONFIG.backup.$(date +%Y%m%d_%H%M%S)"

echo "Backing up config to $BACKUP"
sudo cp "$CONFIG" "$BACKUP"

if grep -q "^dtoverlay=rpi-tv" "$CONFIG"; then
    echo "dtoverlay=rpi-tv is already present in config.txt"
else
    echo "Adding dtoverlay=rpi-tv to config.txt..."
    if grep -q "^dtparam=i2c_arm=on" "$CONFIG"; then
        # Insert after the dtparam=i2c_arm=on line
        sudo sed -i "/^dtparam=i2c_arm=on/a dtoverlay=rpi-tv" "$CONFIG"
    else
        # Add to the end if i2c line is missing
        echo "dtparam=i2c_arm=on not found — adding overlay at the end"
        echo "" | sudo tee -a "$CONFIG" > /dev/null
        echo "dtoverlay=rpi-tv" | sudo tee -a "$CONFIG" > /dev/null
    fi
    echo "Overlay added. Please reboot your Pi:"
    echo "sudo reboot"
fi
