#!/bin/bash

CONFIG_FILE="/boot/config.txt"

# Backup the original config.txt
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# Ensure the required lines are present
grep -qxF 'dtparam=i2c_arm=on' "$CONFIG_FILE" || echo 'dtparam=i2c_arm=on' >> "$CONFIG_FILE"
grep -qxF 'dtoverlay=dvb-t-c-tvhat' "$CONFIG_FILE" || echo 'dtoverlay=dvb-t-c-tvhat' >> "$CONFIG_FILE"

echo "✅ TV HAT config applied. Reboot required."
