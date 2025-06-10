# 🧸 ToyShop Projesi Çalıştırma Kılavuzu

## 🚀 Hızlı Başlangıç (Önizleme Modu)

### Gereksinimler:

- **Node.js** (v16 veya üzeri)
- **npm** (Node.js ile birlikte gelir)

### Adımlar:

```bash
# 1. Bağımlılıkları yükle
npm install

# 2. Projeyi başlat
npm run dev

# 3. Tarayıcıda aç
# http://localhost:3000
```

**✅ Bu şekilde çalıştırdığınızda:**

- Modern ToyShop arayüzünü görebilirsiniz
- Tüm sayfalar çalışır (Ana Sayfa, Ürünler, Sepet, vb.)
- Mock oyuncak verileri ile test edebilirsiniz
- Frontend geliştirme yapabilirsiniz

---

## 🏗️ Tam Mikroservis Kurulumu (.NET + Docker)

### Gereksinimler:

- **.NET 8 SDK** ([İndir](https://dotnet.microsoft.com/download/dotnet/8.0))
- **Docker Desktop** ([İndir](https://www.docker.com/products/docker-desktop))
- **PowerShell** (Windows için)

### Windows Otomatik Kurulum:

```powershell
# Yönetici olarak PowerShell açın
.\setup.ps1
```

### Manuel Docker Kurulumu:

```bash
# 1. src klasörüne git
cd src

# 2. Docker servislerini başlat
docker-compose up -d --build

# 3. Servislerin ayakta olmasını bekle (2-3 dakika)

# 4. Veritabanı migration'larını çalıştır
cd Services/Ordering/Ordering.API
dotnet ef database update
```

**✅ Tam kurulumda çalışacak servisler:**

| Servis                  | URL                    | Açıklama                    |
| ----------------------- | ---------------------- | --------------------------- |
| **ToyShop Web**         | https://localhost:6065 | Ana web uygulaması          |
| **API Gateway**         | https://localhost:6064 | YARP API Gateway            |
| **Catalog API**         | https://localhost:6060 | Oyuncak kataloğu            |
| **Basket API**          | https://localhost:6061 | Sepet servisi               |
| **Discount gRPC**       | https://localhost:6062 | İndirim servisi             |
| **Ordering API**        | https://localhost:6063 | Sipariş servisi             |
| **RabbitMQ Management** | http://localhost:15672 | Mesaj kuyruğu (guest/guest) |

---

## 🔧 Geliştirme Modu

### Frontend Geliştirme:

```bash
# Node.js önizleme modunda çalıştır
npm run dev
```

### Backend Geliştirme:

```bash
# Sadece bir servisi çalıştır
cd src/Services/Catalog/Catalog.API
dotnet run

# Veya tüm servisleri Docker ile
cd src
docker-compose up -d
```

---

## 🐛 Sorun Giderme

### Port Çakışması:

```bash
# Kullanılan portları kontrol et
netstat -an | findstr :3000
netstat -an | findstr :6065

# Farklı port kullan
PORT=3001 npm run dev
```

### Docker Sorunları:

```bash
# Docker temizle
docker-compose down
docker system prune -f

# Yeniden başlat
docker-compose up -d --build
```

### .NET Sorunları:

```bash
# NuGet paketlerini geri yükle
dotnet restore src/eshop-microservices.sln

# Temiz build
dotnet clean src/eshop-microservices.sln
dotnet build src/eshop-microservices.sln
```

---

## 📱 Test Etme

### Önizleme Modu Test:

1. http://localhost:3000 adresine git
2. "Oyuncaklar" sayfasını kontrol et
3. Ürün detaylarına bak
4. Sepete ekleme işlemini test et

### Tam Sistem Test:

1. https://localhost:6065 adresine git
2. Gerçek API'lerden veri çekildiğini kontrol et
3. Sepete ürün ekle
4. Sipariş oluştur
5. RabbitMQ'da mesajları kontrol et

---

## 🎯 Hangi Yöntemi Seçmeliyim?

### **Önizleme Modu** kullan eğer:

- ✅ Sadece frontend'i görmek istiyorsanız
- ✅ Hızlı bir demo yapmak istiyorsanız
- ✅ .NET kurmak istemiyorsanız
- ✅ UI/UX geliştirme yapacaksanız

### **Tam Kurulum** kullan eğer:

- ✅ Gerçek mikroservisleri test etmek istiyorsanız
- ✅ Backend geliştirme yapacaksanız
- ✅ Production'a yakın ortam istiyorsanız
- ✅ API'leri test etmek istiyorsanız

---

## 🚦 Başlangıç Önerisi

1. **İlk olarak önizleme modunu deneyin:**

   ```bash
   npm install
   npm run dev
   ```

2. **Beğendiyseniz tam kuruluma geçin:**
   ```bash
   .\setup.ps1  # Windows
   # veya
   cd src && docker-compose up -d  # Manuel
   ```

## 📞 Yardım

Sorun yaşarsanız:

- ✅ Log'ları kontrol edin: `docker-compose logs`
- ✅ Port'ların boş olduğundan emin olun
- ✅ Docker Desktop'ın çalıştığını kontrol edin
- ✅ .NET 8 SDK'nın kurulu olduğunu kontrol edin

**İyi eğlenceler! 🎉🧸**
