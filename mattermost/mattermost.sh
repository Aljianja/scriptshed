#!/bin/bash

source ./all-env.sh

# Install prerequisites for building Mattermost
sudo apt-get update
sudo apt-get install -y git make

# Clone the Mattermost source code
git clone https://github.com/mattermost/mattermost.git
cd mattermost

# Build Mattermost from source
# This assumes there are instructions in the repository for building the server
# Replace the following with the actual build commands based on the repo's README
make build-server

# Set up the Mattermost directories
sudo mv mattermost ${MATTERMOST_DIR}
sudo mkdir ${MATTERMOST_DIR}/data

# Set Up Mattermost User
sudo useradd --system --user-group mattermost
sudo chown -R mattermost:mattermost ${MATTERMOST_DIR}
sudo chmod -R g+w ${MATTERMOST_DIR}

# Configure Mattermost Database Settings in config.json
# You might need to modify the config.json file manually or via the script to set database connection details

