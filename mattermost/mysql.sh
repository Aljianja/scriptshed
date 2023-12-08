#!/bin/bash

# Install MySQL
sudo apt-get install mysql-server
sudo mysql_secure_installation

# Set up MySQL database and user
sudo mysql -u root -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
sudo mysql -u root -e "CREATE DATABASE ${MYSQL_DATABASE};"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

