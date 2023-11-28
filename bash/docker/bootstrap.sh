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

