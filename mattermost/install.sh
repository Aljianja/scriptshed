#!/bin/bash

# Update System
sudo apt update && sudo apt upgrade -y

# Install MySQL
sudo apt-get install mysql-server
sudo mysql_secure_installation

# Set up MySQL database and user
sudo mysql -u root -e "CREATE USER 'mmuser'@'%' IDENTIFIED BY 'mmuser-password';"
sudo mysql -u root -e "CREATE DATABASE mattermost;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON mattermost.* TO 'mmuser'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Fetch the latest release version from GitHub
latest_version=$(curl -s https://api.github.com/repos/mattermost/mattermost/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

# Clone the repository
git clone https://github.com/mattermost/mattermost.git
cd mattermost-server

# Checkout the latest version
git checkout tags/$latest_version

# Build the server
make build-server

# Move the built server to /opt and create the data directory
sudo mv mattermost /opt
sudo mkdir /opt/mattermost/data

# Set Up Mattermost User
sudo useradd --system --user-group mattermost
sudo chown -R mattermost:mattermost /opt/mattermost
sudo chmod -R g+w /opt/mattermost

# Set Up Mattermost as a Service
echo -e "[Unit]\nDescription=Mattermost\nAfter=network.target\nAfter=mysql.service\nBindsTo=mysql.service\n\n[Service]\nType=notify\nExecStart=/opt/mattermost/bin/mattermost\nTimeoutStartSec=3600\nKillMode=mixed\nRestart=always\nRestartSec=10\nWorkingDirectory=/opt/mattermost\nUser=mattermost\nGroup=mattermost\nLimitNOFILE=49152\n\n[Install]\nWantedBy=mysql.service" | sudo tee /lib/systemd/system/mattermost.service

# Start Mattermost Service
sudo systemctl daemon-reload
sudo systemctl start mattermost.service
sudo systemctl enable mattermost.service
