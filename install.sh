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

# Create Docker Network (Fix IP Issue)
docker network create --driver=bridge windows_net

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
      USERNAME: "MASTER"
      PASSWORD: "admin@123"
      RAM_SIZE: "4G"
      CPU_CORES: "4"
      DISK_SIZE: "400G"
      DISK2_SIZE: "100G"
    networks:
      - windows_net
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
networks:
  windows_net:
    driver: bridge
EOL

# Show Config File
cat windows10.yml

# Start the Windows Container
sudo docker-compose -f windows10.yml up -d

# Wait for container to start
sleep 5

# Get Container IP (Fix)
WINDOWS_IP=$(docker inspect -f '{{range .NetworkSettings.Networks.windows_net}}{{.IPAddress}}{{end}}' windows)

# Display Connection Info
echo "--------------------------------------------------"
echo "✅ Windows 10 Remote Desktop (RDP) is Ready! 🚀"
echo "📌 IP Address  : $WINDOWS_IP"
echo "👤 Username    : MASTER"
echo "🔑 Password    : admin@123"
echo "--------------------------------------------------"
echo "Use 'mstsc /v:$WINDOWS_IP' to connect via Remote Desktop!"
echo "--------------------------------------------------"
