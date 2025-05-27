#!/bin/bash

set -e

# Update and install tools
sudo apt-get update -y
sudo apt-get install -y curl

# IP'nin hazır olmasını bekle
while ! hostname -I | grep -q "192.168.56.111"; do
  echo "Waiting for IP to be ready..."
  sleep 2
done

SERVER_IP="192.168.56.110"
K3S_TOKEN=$(cat /vagrant/shared/node-token)

# Install K3s agent - NODE-IP sabitlemesi
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.111" K3S_URL="https://${SERVER_IP}:6443" K3S_TOKEN="${K3S_TOKEN}" sh -

# kubectl symlink
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

echo "Setting up aliases"
echo "alias k='sudo kubectl'" >> /home/vagrant/.bashrc