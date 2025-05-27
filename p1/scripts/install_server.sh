#!/bin/bash

set -e

# Update and install tools
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl iptables iptables-persistent

# IP'nin hazır olmasını bekle
while ! hostname -I | grep -q "192.168.56.110"; do
  echo "Waiting for IP to be ready..."
  sleep 2
done

# IP forwarding aktif hale getir
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sysctl -p

# Install K3s server - NODE-IP sabitlemesi
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110" sh -

# kubectl symlink
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

# node-token'u paylaşılan klasöre yaz
sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/shared/node-token

echo "Setting up aliases"
echo "alias k='sudo kubectl'" >> /home/vagrant/.bashrc