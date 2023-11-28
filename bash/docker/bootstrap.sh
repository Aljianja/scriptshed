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
            curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable"
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

install_docker_compose() {
    # Get latest docker-compose release
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

    # Check if the docker-compose release is available
    if [ -z "$DOCKER_COMPOSE_VERSION"]; then
        echo "Failed to fetch the latest version of Docker compose"
        exit 1
    fi

    echo "Installing Docker Compose version: $DOCKER_COMPOSE_VERSION"

    # Download Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64" -o /usr/bin/docker-compose

    # Apply executable permission to the binary
    sudo chmod +x /usr/bin/docker-compose

    # Verify the installation
    if ! command -v docker-compose &> /dev/null; then
        echo "Docker Compose could not be installed. Please check the installation logs for errors."
        exit 1
    else
        echo "Docker Compose installed successfully."
        docker-compose version
    fi
}

# Main script starts here
detect_distro
echo "Detected Distribution: $DISTRO, Version: $VER"
install_docker
install_docker_compose

# Verify Docker installation
if ! command -v docker &> /dev/null; then
    echo "Docker could not be installed. Please check the installation logs for errors."
    exit 1
else
    echo "Docker installed successfully."
    docker --version
fi
