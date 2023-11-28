#!/bin/bash

# Function to detect Linux Distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO=$(echo $DISTRIB_ID | tr '[:upper:]' '[:lower:]')
        VER=$DISTRIB_RELEASE
    else
        echo "Unable to detect Linux distribution."
        exit 1
    fi
}

# Unified installation function
install_docker() {
    case $DISTRO in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            sudo apt-get update
            sudo apt-get install -y docker-ce
            ;;
        centos|fedora|rhel|redhat)
            sudo yum check-update
            curl -fsSL https://get.docker.com/ | sh
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
        suse|opensuse|sles)
            # Add commands for SuSE here
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

# Main script starts here
detect_distro
echo "Detected Distribution: $DISTRO, Version: $VER"
install_docker

# Verify Docker installation
if ! command -v docker &> /dev/null; then
    echo "Docker could not be installed. Please check the installation logs for errors."
    exit 1
else
    echo "Docker installed successfully."
    docker --version
fi
