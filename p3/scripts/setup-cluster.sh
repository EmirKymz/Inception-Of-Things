#!/bin/bash

# K3d cluster oluşturma
k3d cluster create iot-cluster --port "8080:80@loadbalancer" --port "8443:443@loadbalancer"

# Cluster durumunu kontrol et
kubectl cluster-info
kubectl get nodes