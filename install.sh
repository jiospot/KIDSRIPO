#!/bin/bash

# Run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)" 
    exit 1
fi

# Update packages
apt update

# Install Docker and Docker Compose
apt install -y docker.io docker-compose

# Verify Docker installation
docker --version || { echo "Docker installation failed"; exit 1; }

# Print current working directory
pwd

# Create directory and navigate
mkdir -p dockercomp
cd dockercomp

# Create docker-compose file
cat <<EOL > windows10.yml
version: '3'
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "10"
      USERNAME: "KIDSSIR"
      PASSWORD: "admin@123"
      RAM_SIZE: "4G"
      CPU_CORES: "4"
      DISK_SIZE: "400G"
      DISK2_SIZE: "100G"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
      - "3389:3389/udp"
    stop_grace_period: 2m
EOL

# Display the created file
cat windows10.yml

# Start the container
sudo docker-compose -f windows10.yml up -d

echo "Windows 10 container setup complete! 🚀"
