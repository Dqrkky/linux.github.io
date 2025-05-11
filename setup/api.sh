#!/bin/bash

# Create systemd service file for API
sudo tee /etc/systemd/system/api.service > /dev/null <<EOF
[Unit]
Description=Api
After=network.target

[Service]
User=dqrk
WorkingDirectory=/home/dqrk/Api
ExecStart=/home/dqrk/Api/start.sh
Restart=always
RestartSec=3
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable api
sudo systemctl start api

# Show status
sudo systemctl status api
