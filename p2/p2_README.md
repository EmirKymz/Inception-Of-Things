# Inception of Things – P2: K3s & Ingress with Static HTML Apps

## 📚 Proje Amacı

Bu adımda tek bir sanal makine içinde K3s (lightweight Kubernetes) kurulumu yapılarak, 3 adet basit web uygulamasının Ingress ile hostname bazlı yönlendirme ile servis edilmesi amaçlanır.

Her uygulama, farklı bir hostname (örneğin `app1.com`, `app2.com`) ile erişilecek şekilde yapılandırılmıştır.  
Tüm yapı, Vagrant + VirtualBox ortamında çalışmaktadır.

...

## ✅ Sonuç

Bu aşamada:

- Tek bir VM üzerine K3s kurulumu başarıyla tamamlandı
- 3 farklı web uygulaması dağıtıldı
- Hostname bazlı yönlendirme başarıyla yapılandırıldı
- Görsel ve sade bir yapı ile savunma için ideal bir ortam oluşturuldu
