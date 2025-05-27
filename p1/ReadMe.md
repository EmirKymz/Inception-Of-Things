# Inception of Things - P1

## 📚 Proje Hakkında

Bu proje, **Vagrant** kullanarak Debian tabanlı iki sanal makine üzerinde **K3s** kurulumu yapmayı hedefler.  
K3s, hafif bir Kubernetes dağıtımıdır. Bu çalışma sayesinde Kubernetes temelleri küçük bir ortamda öğlenilir.

---

## 🌟 Hedefler

- 1 adet **K3s Server** (Controller) makinesi oluşturmak
- 1 adet **K3s Worker** (Agent) makinesi oluşturmak
- İkisi arasında doğru bir şekilde bağlantı kurmak
- `kubectl` aracıyla cluster yönetimini sağlamak
- Minimum kaynak kullanımı ile çalışabilir bir sistem inşa etmek

---

## ⚙️ Kullanılan Teknolojiler

| Teknoloji | Açıklama |
|:----------|:---------|
| Vagrant | VM yönetimi için |
| VirtualBox | Sanallaştırma altyapısı |
| Debian Bullseye64 | Hafif, hızlı, stabil işletim sistemi |
| K3s | Lightweight Kubernetes dağıtımı |
| Shell Script | Otomasyon betikleri |

---

## 📦 Proje Yapısı

```
p1/
├── Vagrantfile
├── scripts/
│   ├── install_server.sh
│   └── install_worker.sh
└── shared/
```

- **Vagrantfile:** 2 VM tanımı (Server + Worker)
- **scripts/install_server.sh:** Server'a K3s kurulumu
- **scripts/install_worker.sh:** Worker'a K3s agent kurulumu
- **shared/:** Server tarafından oluşturulan `node-token` dosyası burada tutulur.

---

## 🚀 K3s Nedir?

- K3s, **Rancher Labs** tarafından geliştirilmiş, CNCF onaylı bir **hafif Kubernetes** dağıtımıdır.
- Normal Kubernetes kurulumlarının aksine:
  - Daha az bellek ve CPU kullanır
  - Daha hızlı kurulup başlar
  - Tek bir binary dosyası vardır (`k3s`)

Bu projede **Kubernetes'in karmaşıklığıyla uğraşmadan**, doğrudan temel cluster yapısını görebilmemiz için **K3s** seçilmiştir.

---

## 🛠️ Nasıl Kurulur?

1. Bu dizinde (`p1/`) terminal açın.

2. Vagrant makinelerini başlatın:
   ```bash
   vagrant up
   ```

3. Vagrant şu işlemleri yapacak:
   - `debian/bullseye64` box'ını indirir (ilk seferde)
   - EkaymazS (Server) makinesini kurar ve başlatır
   - EkaymazSW (Worker) makinesini kurar ve başlatır
   - Server üzerinde K3s Server kurulumu yapar
   - Worker üzerinde K3s Agent kurulumu yapar
   - İki makine arasında otomatik bağlantı sağlar

4. Server'a SSH ile bağlanın ve cluster'ı kontrol edin:
   ```bash
   vagrant ssh EkaymazS
   kubectl get nodes
   ```

🔹 Örnek çıktı:
```
NAME        STATUS   ROLES                  AGE   VERSION
ekaymazs    Ready    control-plane,master    5m    v1.32.3+k3s1
ekaymazsw   Ready    <none>                  2m    v1.32.3+k3s1
```

---

## ⚡ Önemli İpuçları

- `vagrant reload EkaymazS` → Sadece Server'ı yeniden başlatır.
- `vagrant reload EkaymazSW` → Sadece Worker'ı yeniden başlatır.
- `vagrant halt` → Tüm makineleri durdurur.
- `vagrant destroy` → Tüm makineleri siler.

---

## 🐋 Karşılaşılan Sorunlar ve Çözümleri

| Sorun | Çözüm |
|:------|:------|
| `iptables-persistent` kurulurken takılma | `DEBIAN_FRONTEND=noninteractive` eklendi |
| K3s Server `Job failed` hatası | `IP forwarding` aktif edildi |
| Worker Server'a bağlanamıyor | `shared/` klasör ile `node-token` doğru şekilde paylaşılıyor |
| RAM yetmemesi | 1024 MB RAM ayarlandı |

---

## 📜 Notlar

- Her iki makine de private network IP'si ile (192.168.56.110 ve 192.168.56.111) çalışır.
- SSH bağlantısı `vagrant` kullanıcısı ve özel anahtar ile yapılır.
- `kubectl` komutu doğrudan Server VM içinde kullanılabilir.

---

# 🏁 Sonuç

Bu proje sayesinde küçük kaynaklarla tam çalışan bir **Kubernetes Cluster** (Server + Worker) ortamı oluşturuldu.  
**K3s** kullanımı sayesinde minimum RAM, CPU tüketimi ile maksimum öğrenim sağlandı. 🚀

---

# 🌟 Yapılacaklar

- [ ] K3s cluster üzerinde örnek bir uygulama deploy edilebilir (nginx, httpd vb.)
- [ ] Node'lar üzerine pod scheduling denenebilir.
- [ ] Ingress Controller kurulumu eklenip servisler dış dünyaya açılabilir.

