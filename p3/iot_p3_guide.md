# IoT Part 3: K3d ve Argo CD ile CI/CD Kurulumu

## Gereksinimler ve Hazırlık

### 1. Genel Bakış
Bu bölümde Vagrant kullanmadan, doğrudan Debian sanal makinende:
- K3d kurulumu yapacağız
- Argo CD ile continuous integration kuracağız  
- GitHub repository'den otomatik deployment sağlayacağız
- İki namespace oluşturacağız: `argocd` ve `dev`

### 2. Gerekli Yazılımların Kurulumu

#### Kurulum Script'i (`p3/scripts/install.sh`)
```bash
#!/bin/bash

# Sistem güncellemesi
sudo apt update && sudo apt upgrade -y

# Docker kurulumu
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Docker'ı normal kullanıcı ile çalıştırma
sudo usermod -aG docker $USER

# kubectl kurulumu
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# K3d kurulumu
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Argo CD CLI kurulumu
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo "Kurulum tamamlandı! Lütfen yeniden giriş yapın veya 'newgrp docker' komutunu çalıştırın."
```

### 3. K3d Cluster Kurulumu

#### Cluster Oluşturma Script'i (`p3/scripts/setup-cluster.sh`)
```bash
#!/bin/bash

# K3d cluster oluşturma
k3d cluster create iot-cluster --port "8080:80@loadbalancer" --port "8443:443@loadbalancer"

# Cluster durumunu kontrol et
kubectl cluster-info
kubectl get nodes
```

### 4. Namespace'lerin Oluşturulması

#### Namespace Config'i (`p3/confs/namespaces.yaml`)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
---
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

### 5. Argo CD Kurulumu

#### Argo CD Kurulum Script'i (`p3/scripts/setup-argocd.sh`)
```bash
#!/bin/bash

# Namespace'leri oluştur
kubectl apply -f ../confs/namespaces.yaml

# Argo CD kurulumu
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Argo CD server'ın hazır olmasını bekle
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Argo CD admin şifresini al
echo "Argo CD admin şifresi:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Argo CD UI'ya erişım için port forwarding (alternatif portlar)
echo "Argo CD UI'ya erişmek için şu komutlardan birini dene:"
echo "kubectl port-forward svc/argocd-server -n argocd 8081:443"
echo "kubectl port-forward svc/argocd-server -n argocd 9090:443"
echo "kubectl port-forward svc/argocd-server -n argocd 7070:443"
```

### 6. GitHub Repository Hazırlığı

#### Repository Yapısı
GitHub'da public bir repository oluştur. İsimde takım üyelerinden birinin login'i olsun.

```
your-github-repo/
├── deployment.yaml
├── service.yaml
└── README.md
```

#### Deployment Config'i (`deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wil-playground
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wil-playground
  template:
    metadata:
      labels:
        app: wil-playground
    spec:
      containers:
      - name: wil-playground
        image: wil42/playground:v1
        ports:
        - containerPort: 8888
---
apiVersion: v1
kind: Service
metadata:
  name: wil-playground-service
  namespace: dev
spec:
  selector:
    app: wil-playground
  ports:
    - protocol: TCP
      port: 8888
      targetPort: 8888
  type: ClusterIP
```

### 7. Argo CD Application Konfigürasyonu

#### Application Config'i (`p3/confs/application.yaml`)
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-playground-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO-NAME
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### 8. Kurulum Adımları

#### 1. Kurulum Script'ini Çalıştır
```bash
chmod +x p3/scripts/install.sh
./p3/scripts/install.sh
# Yeniden giriş yap veya: newgrp docker
```

#### 2. K3d Cluster'ı Oluştur
```bash
chmod +x p3/scripts/setup-cluster.sh
./p3/scripts/setup-cluster.sh
```

#### 3. Argo CD'yi Kur
```bash
chmod +x p3/scripts/setup-argocd.sh
./p3/scripts/setup-argocd.sh
```

#### 4. Argo CD Application'ı Deploy Et
```bash
# GitHub repo URL'ini güncelle
kubectl apply -f p3/confs/application.yaml
```

### 9. Test ve Doğrulama

#### Namespace'leri Kontrol Et
```bash
kubectl get ns
# argocd ve dev namespace'lerini görmeli
```

#### Pod'ları Kontrol Et
```bash
kubectl get pods -n dev
kubectl get pods -n argocd
```

#### Application'a Erişim
```bash
# Port forwarding ile test
kubectl port-forward svc/wil-playground-service -n dev 8888:8888
# Başka terminalde: curl http://localhost:8888/
```

### 10. Version Değişikliği Testi

#### GitHub'da Version Değiştir
```bash
# deployment.yaml dosyasında v1'i v2 yap
sed -i 's/wil42\/playground:v1/wil42\/playground:v2/g' deployment.yaml
git add .
git commit -m "Update to v2"
git push
```

#### Argo CD'de Sync'i Kontrol Et
- Argo CD UI'da sync durumunu kontrol et
- Automatic sync aktif olmalı

### 11. Dizin Yapısı

```
p3/
├── scripts/
│   ├── install.sh
│   ├── setup-cluster.sh
│   └── setup-argocd.sh
└── confs/
    ├── namespaces.yaml
    └── application.yaml
```

### 12. Önemli Notlar

#### 8080 Portu Meşgul Hatası
```bash
# Hangi process 8080 kullanıyor kontrol et
sudo lsof -i :8080
# veya
sudo netstat -tulpn | grep :8080

# Process'i öldür (gerekirse)
sudo kill -9 PID_NUMBER
```

#### Alternatif Port Forwarding Komutları
```bash
# Farklı portlar dene
kubectl port-forward svc/argocd-server -n argocd 8081:443
kubectl port-forward svc/argocd-server -n argocd 9090:443
kubectl port-forward svc/argocd-server -n argocd 7070:443

# Argo CD'ye erişim
# Browser'da: https://localhost:8081 (ya da kullandığın port)
# Username: admin
# Password: (script'ten aldığın şifre)
```

#### NodePort ile Kalıcı Erişim (Önerilen)
```bash
# Argo CD server'ı NodePort olarak expose et
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort"}}'

# Port numarasını öğren
kubectl get svc argocd-server -n argocd

# Erişim: https://localhost:PORT_NUMBER
```

- **Docker kurulumundan sonra logout/login yapman gerekir**
- **GitHub repository public olmalı**  
- **Argo CD admin şifresini kaydet**
- **Port forwarding'i test için kullan**
- **Version değişikliği GitHub'da otomatik sync'lenecek**

### 13. Troubleshooting

#### Yaygın Sorunlar
- Docker permission denied: `newgrp docker` 
- Argo CD pods pending: Disk alanını kontrol et
- GitHub sync problemi: Repository URL'sini kontrol et
- Port forwarding çalışmıyor: kubectl proxy dene

#### Useful Commands
```bash
# Cluster bilgisi
kubectl cluster-info

# Tüm kaynakları göster
kubectl get all -A

# Argo CD şifresini tekrar al
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Logs kontrol et
kubectl logs -n argocd deployment/argocd-server
```

Bu rehber PDF'deki tüm gereksinimleri karşılıyor ve Debian sanal makinende çalışacak şekilde optimize edilmiş. Adım adım takip edersen başarılı bir şekilde Part 3'ü tamamlayabilirsin!