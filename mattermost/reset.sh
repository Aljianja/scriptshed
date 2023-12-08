#!/bin/bash

# Stop services if they are running
sudo systemctl stop mattermost
sudo systemctl stop nginx
sudo systemctl stop mysql

# Remove Mattermost directory
sudo rm -rf /opt/mattermost

# Uninstall and remove MySQL
sudo apt-get remove --purge mysql-server mysql-client mysql-common -y
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /var/lib/mysql
sudo rm -rf /etc/mysql

# Uninstall and remove NGINX
sudo apt-get remove --purge nginx nginx-common -y
sudo apt-get autoremove -y
sudo apt-get autoclean

# Uninstall Go (if installed manually)
sudo rm -rf /usr/local/go

# Remove Go binaries from PATH in .bashrc or .profile if added

# Remove Mattermost user
sudo userdel -r mattermost

echo "Uninstallation complete."
