#!/bin/bash

# Log file
LOG_FILE="aws_install.log"

# Variables
AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
AWS_CLI_ZIP="awscliv2.zip"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %T") - $1" | tee -a "$LOG_FILE"
}

# Function to handle errors
handle_error() {
    log_message "Error on line $1. Exiting."
    exit 1
}

# Trap errors and pass the line number to handle_error function
trap 'handle_error $LINENO' ERR

log_message "Starting AWS CLI v2 installation..."

# Update the package manager
log_message "Updating package manager..."
sudo apt-get update -y >> "$LOG_FILE" 2>&1

# Install required packages
log_message "Installing required packages..."
sudo apt-get install unzip curl -y >> "$LOG_FILE" 2>&1

# Download the AWS CLI v2 installation package
log_message "Downloading AWS CLI v2..."
curl "$AWS_CLI_URL" -o "$AWS_CLI_ZIP" >> "$LOG_FILE" 2>&1

# Unzip the downloaded package
log_message "Unzipping the AWS CLI v2 package..."
unzip "$AWS_CLI_ZIP" >> "$LOG_FILE" 2>&1

# Install AWS CLI v2
log_message "Installing AWS CLI v2..."
sudo ./aws/install >> "$LOG_FILE" 2>&1

# Verify the installation
log_message "Verifying AWS CLI v2 installation..."
aws --version >> "$LOG_FILE" 2>&1

# Cleanup
log_message "Cleaning up installation files..."
rm -rf aws
rm "$AWS_CLI_ZIP"

log_message "AWS CLI v2 installation completed successfully."