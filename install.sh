#!/bin/bash

# Run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)" 
    exit 1
fi

# Update System
apt update

# Install Docker & Docker Compose
apt install -y docker.io docker-compose

# Verify Docker Installation
docker --version || { echo "Docker installation failed"; exit 1; }

# Create Directory & Navigate
mkdir -p dockercomp
cd dockercomp

# Create Docker Compose File
cat <<EOL > windows10.yml
version: '3'
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "10"
      USERNAME: "KIDS"
      PASSWORD: "admin@123"
      RAM_SIZE: "8G"
      CPU_CORES: "16"
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
    command: >
      powershell -Command "
        Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -Name 'fDenyTSConnections' -Value 0;
        Enable-NetFirewallRule -DisplayGroup 'Remote Desktop';
        net stop termservice;
        net start termservice;
      "
EOL

# Show Config File
cat windows10.yml

# Start the Windows Container
sudo docker-compose -f windows10.yml up -d

echo "Windows 10 container with RDP setup complete! 🚀"
