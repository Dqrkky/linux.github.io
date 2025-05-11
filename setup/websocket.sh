#!/bin/bash

# Create systemd service file for API
sudo tee /etc/systemd/system/websocket.service > /dev/null <<EOF
[Unit]
Description=WebSocket
After=network.target

[Service]
User=dqrk
WorkingDirectory=/home/dqrk/Websocket
ExecStart=/home/dqrk/Websocket/start.sh
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable websocket
sudo systemctl start websocket

# Show status
sudo systemctl status websocket
