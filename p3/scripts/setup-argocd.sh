#!/bin/bash

# Namespace'leri oluştur
kubectl apply -f '/home/ekaymaz/Desktop/iot/p3/confs/namespaces.yaml'

# Argo CD kurulumu
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Argo CD server'ın hazır olmasını bekle
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Argo CD admin şifresini al
echo "Argo CD admin şifresi:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Argo CD UI'ya erişım için port forwarding
echo "Argo CD UI'ya erişmek için başka bir terminalde şu komutu çalıştırın:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"