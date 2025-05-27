# Inception of Things – P2: K3s & Ingress with Static HTML Apps

## 📚 Proje Amacı

Bu adımda tek bir sanal makine içinde **K3s (lightweight Kubernetes)** kurulumu yapılarak, 3 adet basit web uygulamasının **Ingress ile hostname bazlı yönlendirme** ile servis edilmesi amaçlanır.

Her uygulama, farklı bir hostname (örneğin `app1.com`, `app2.com`) ile erişilecek şekilde yapılandırılmıştır.  
Tüm yapı, **Vagrant** + **VirtualBox** ortamında çalışmaktadır.

---

## 🔧 Kullanılan Teknolojiler

| Teknoloji       | Açıklama                                         |
|-----------------|--------------------------------------------------|
| Debian Bullseye | Hafif ve kararlı Linux dağıtımı (VM tabanlı)     |
| K3s             | CNCF destekli, tek binary'li Kubernetes dağıtımı |
| Traefik         | K3s’in varsayılan Ingress Controller’ı           |
| Nginx           | Web sunucusu olarak kullanıldı                   |
| Vagrant         | VM oluşturma ve otomasyon                        |
| VirtualBox      | Sanal makine altyapısı                           |

---

## 🧱 Mimari Yapı

- 1 adet sanal makine (`EkaymazS`)
- Bu makine üzerinde:
  - `K3s` kuruludur
  - 3 adet **Deployment** nesnesi vardır:
    - `app1`: nginx, 1 replica
    - `app2`: nginx, 3 replica
    - `app3`: nginx, 1 replica
  - Her bir uygulama, `index.html` dosyası ile farklı sayfa sunar
  - `Ingress` ile hostname bazlı yönlendirme yapılır:
    - `app1.com` → `app1`
    - `app2.com` → `app2`
    - Diğer her şey → `app3` (default)

---

## 📁 Klasör Yapısı

```
p2/
├── Vagrantfile
├── scripts/
│   └── install_server.sh
├── index/
│   ├── app1/index.html
│   ├── app2/index.html
│   └── app3/index.html
├── confs/
│   ├── app1-deployment.yaml
│   ├── app2-deployment.yaml
│   ├── app3-deployment.yaml
│   └── ingress.yaml
```

---

## 🚀 Kurulum

1. Terminalden `p2/` klasörüne girin:

```bash
cd p2
```

2. Sanal makineyi başlatın:

```bash
vagrant up
```

3. Vagrant:
   - Debian VM kurar
   - `K3s` kurar
   - `kubectl` bağlantısını ayarlar
   - Deployment ve Ingress kaynaklarını otomatik olarak uygular

4. VM'e bağlanmak için:

```bash
vagrant ssh EkaymazS
```

---

## 🔍 Yapılandırma Detayları

### ✅ Deployment ve `index.html` Bağlantısı

- Her uygulama `nginx` image’ı ile çalışır
- `index.html` dosyası, `hostPath` volume ile `/usr/share/nginx/html/` dizinine mount edilir

**Örnek: `app2` Deployment**

```yaml
volumeMounts:
  - name: app-two-volume
    mountPath: /usr/share/nginx/html
volumes:
  - name: app-two-volume
    hostPath:
      path: /vagrant/index/app2
```

### ✅ Replica

- `app2` için 3 replica ayarlanmıştır:

```yaml
spec:
  replicas: 3
```

### ✅ Ingress Yönlendirmesi

```yaml
rules:
  - host: app1.com
    http:
      paths:
        - path: /
          backend:
            service:
              name: app-one
              port:
                number: 80
  - host: app2.com
    http:
      paths:
        - path: /
          backend:
            service:
              name: app-two
              port:
                number: 80
  - http:
      paths:
        - path: /
          backend:
            service:
              name: app-three
              port:
                number: 80
```

---

## 🧪 Test & Doğrulama

### 🔧 `/etc/hosts` dosyasına yetkiniz yoksa:

Yine de terminalden test yapabilirsiniz:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl http://192.168.56.110     # default → app3
```

### 🔍 Replica kontrolü:

```bash
kubectl get deployment app-two
kubectl get pods -l app=app-two
```

Beklenen: 3 adet pod çalışıyor olmalı.

---

## 🧠 Savunma için Gösterebileceğin Şeyler

| Gösterim          | Komut                                                   |
|-------------------|----------------------------------------------------------|
| Deployment'lar    | `kubectl get deployments`                                |
| Pod listesi       | `kubectl get pods -o wide`                               |
| Ingress yönlendirme | `kubectl get ingress && kubectl describe ingress ...`  |
| HTML çıktısı      | `curl -H "Host: appX.com" http://192.168.56.110`         |
| Replica kanıtı    | `kubectl get deployment app2`                            |

---

## 💻 index.html Örnekleri (Her App İçin Farklı)

Her `index.html` dosyası farklı arka plan ve renk ile hazırlanmıştır.  
Sunum sırasında hangi uygulamanın geldiği görsel olarak rahatça anlaşılır.

---

## ✅ Sonuç

Bu aşamada:

- Tek bir VM üzerine K3s kurulumu başarıyla tamamlandı
- 3 farklı web uygulaması dağıtıldı
- Hostname bazlı yönlendirme başarıyla yapılandırıldı
- Görsel ve sade bir yapı ile savunma için ideal bir ortam oluşturuldu

---