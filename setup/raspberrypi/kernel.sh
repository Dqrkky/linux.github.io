#!/bin/bash

# Step 1: Add the Raspberry Pi GPG key
echo "Adding Raspberry Pi GPG key..."
curl -fsSL https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/raspberrypi.gpg

# Step 2: Ensure the sources.list.d entry is correct
echo "Configuring Raspberry Pi repository..."
echo "deb [signed-by=/usr/share/keyrings/raspberrypi.gpg] http://archive.raspberrypi.org/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/raspi.list

# Step 3: Update the package list
echo "Updating package list..."
sudo apt-get update

# Step 4: Install Raspberry Pi kernel and firmware packages
echo "Installing Raspberry Pi kernel and firmware..."
sudo apt install -y raspberrypi-bootloader raspberrypi-kernel

echo "Installation complete!"
