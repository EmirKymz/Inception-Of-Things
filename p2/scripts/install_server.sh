#!/bin/bash

set -e

# Güncelle ve gerekli paketleri yükle
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl iptables iptables-persistent

# IP hazır mı?
while ! hostname -I | grep -q "192.168.56.110"; do
  echo "IP adresi atanması bekleniyor..."
  sleep 2
done

# IP forwarding aktif
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sysctl -p

# K3s kurulumu (node-ip + ingress için flannel iface)
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1" sh -

# kubectl symlink
sudo ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

# K3s çalışıyor mu?
sleep 10
kubectl get nodes

# Uygulamaları deploy et
kubectl apply -f /vagrant/confs/app1-deployment.yaml
kubectl apply -f /vagrant/confs/app2-deployment.yaml
kubectl apply -f /vagrant/confs/app3-deployment.yaml
kubectl apply -f /vagrant/confs/ingress.yaml
