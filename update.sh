#!/bin/bash

# Check if the user has sudo privileges
if sudo -v &> /dev/null; then
    echo "Running with sudo privileges..."
    # Place the command that needs sudo here
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get full-upgrade -y
else
    echo "Running without sudo privileges..."
    # Place the command that doesn't require sudo here
    apt-get update
    apt-get upgrade -y
    apt-get full-upgrade -y
fi
