#!/bin/bash

if ! go version &> /dev/null
then
    # Install Go if not installed
    GO_VERSION="1.18" # Specify the required Go version
    wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    export GOROOT=/usr/local/go
else
    echo "Go is already installed."
fi

if [ ! -d "mattermost" ]; then
    git clone https://github.com/mattermost/mattermost.git
    cd mattermost
    # Use build commands as per the Mattermost repository's instructions
    # Example: make build-server
else
    echo "Mattermost is already cloned."
fi

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

