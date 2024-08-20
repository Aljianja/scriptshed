#!/bin/bash

sudo apt update

# MySQL root password
MYSQL_ROOT_PASSWORD="your_password_here"

# Define the responses to the mysql_secure_installation prompts
SECURE_INSTALLATION_RESPONSES="
Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
Y
Y
Y
"

# Run mysql_secure_installation with automated responses
echo "$SECURE_INSTALLATION_RESPONSES" | mysql_secure_installation