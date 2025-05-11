#!/bin/bash

# Default URL for the requirements.txt
DEFAULT_URL="https://dqrkky.github.io/linux/setup/websocket/requirements.txt"

# You can also specify a custom URL by passing it as an argument
REQUIREMENTS_URL=${1:-$DEFAULT_URL}

# Install python3-venv if not installed
sudo apt-get install -y python3-venv

# Check if the Api directory exists
if [ -d "Websocket" ]; then
  cd Websocket
fi

# Create a Python virtual environment named 'venv'
python3 -m venv venv

echo "Downloading requirements.txt from $REQUIREMENTS_URL..."

# Install the dependencies from the downloaded requirements.txt file
venv/bin/pip install -r $REQUIREMENTS_URL
