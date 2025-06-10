# 🧸 ToyShop - Modern Oyuncak Mağazası

Bu proje .NET 8 mikroservis mimarisi ile geliştirilmiş modern bir oyuncak e-ticaret platformudur. Geliştirme ortamı Node.js ile frontend önizlemesi sağlarken, gerçek uygulama .NET ve Docker ile çalışacak şekilde tasarlanmıştır.

## 🚀 Hızlı Başlangıç

### 1. Frontend (Geliştirme Önizlemesi) ✅ ÇALIŞIYOR

```bash
npm install
npm run dev
# http://localhost:3000 adresinde açılır
```

**Mevcut URL'ler:**

- **Ana Sayfa**: http://localhost:3000/ - Oyuncak kategorileri ve öne çıkan ürünler
- **Oyuncaklar**: http://localhost:3000/products - Tüm oyuncak kataloğu
- **Sepet**: http://localhost:3000/cart - Alışveriş sepeti
- **Siparişler**: http://localhost:3000/orders - Sipariş geçmişi
- **İletişim**: http://localhost:3000/contact - Müşteri desteği
- **Health Check**: http://localhost:3000/api/health - Sistem durumu

### 2. Backend (.NET Mikroservisler) ⚠️ KURULUM GEREKLİ

#### Otomatik Kurulum (Önerilen)

```bash
# Linux/Mac
./start-backend.sh

# Windows
./start-backend.ps1
```

#### Manuel Docker Kurulumu

```bash
cd src
docker-compose up -d
```

#### Manuel .NET Kurulumu

```bash
# Her servisi ayrı terminal'de çalıştırın:
cd src/Services/Catalog/Catalog.API && dotnet run        # Port 6000
cd src/Services/Basket/Basket.API && dotnet run         # Port 6001
cd src/Services/Discount/Discount.Grpc && dotnet run    # Port 6002
cd src/Services/Ordering/Ordering.API && dotnet run     # Port 6003
cd src/ApiGateways/YarpApiGateway && dotnet run         # Port 6004
cd src/WebApps/Shopping.Web && dotnet run               # Port 6005
```

## 📊 Sistem Durumu

| Servis Türü            | URL                              | Durum              | Açıklama                |
| ---------------------- | -------------------------------- | ------------------ | ----------------------- |
| **Frontend (Node.js)** | http://localhost:3000            | ✅ Aktif           | Mock data ile çalışıyor |
| **Health Check**       | http://localhost:3000/api/health | ✅ Aktif           | Sistem durumu           |
| **Backend Gateway**    | https://localhost:6064           | ⚠️ Kurulum Gerekli | .NET API Gateway        |
| **Shopping Web**       | https://localhost:6065           | ⚠️ Kurulum Gerekli | .NET Web Uygulaması     |
| **Catalog API**        | http://localhost:6000            | ⚠️ Kurulum Gerekli | Ürün kataloğu           |
| **Basket API**         | http://localhost:6001            | ⚠️ Kurulum Gerekli | Sepet yönetimi          |
| **Discount gRPC**      | http://localhost:6002            | ⚠️ Kurulum Gerekli | İndirim servisi         |
| **Ordering API**       | http://localhost:6003            | ⚠️ Kurulum Gerekli | Sipariş yönetimi        |

## 🔧 Sorun Giderme

### API Çağrıları Çalışmıyor?

1. **Frontend Mock Modu** (Şu anki durum):

   - ✅ Mock veriler kullanılıyor
   - ✅ Frontend çalışıyor
   - ⚠️ Backend servisleri kullanılamıyor

2. **Backend Kurulum Kontrolü**:

   ```bash
   # Sistem durumunu kontrol et
   curl http://localhost:3000/api/health

   # .NET SDK kontrolü
   dotnet --version

   # Docker kontrolü
   docker --version
   ```

3. **Detaylı Çözüm Kılavuzu**: `API_SORUN_COZUM_KILAVUZU.md` dosyasına bakın

### Hızlı Reset

```bash
# Backend'i durdur
./stop-backend.sh

# Yeniden başlat
./start-backend.sh
```

## 📁 Proje Yapısı

```
toyshop-microservices/
├── 🌐 Frontend (Node.js)
│   ├── package.json                        # Node.js geliştirme kurulumu
│   ├── server.js                          # Geliştirme sunucusu
│   └── API_SORUN_COZUM_KILAVUZU.md       # Sorun giderme kılavuzu
├── 🔧 Kurulum Scriptleri
│   ├── start-backend.sh/.ps1             # Backend başlatma
│   └── stop-backend.sh                    # Backend durdurma
└── 🏗️ Backend (.NET)
    ├── src/
    │   ├── ApiGateways/YarpApiGateway/    # API Gateway (YARP)
    │   ├── BuildingBlocks/                # Paylaşılan kütüphaneler
    │   ├── Services/
    │   │   ├── Basket/Basket.API/        # Sepet Servisi
    │   │   ├── Catalog/Catalog.API/      # Ürün Kataloğu Servisi
    │   │   ├── Discount/Discount.Grpc/   # İndirim Servisi (gRPC)
    │   │   └── Ordering/                 # Sipariş Yönetimi Servisi
    │   └── WebApps/Shopping.Web/         # .NET Web Uygulaması
    └── docker-compose.yml                # Docker kurulumu
```

## 🎯 Özellikler

### Şu Anda Aktif (Frontend)

- ✅ Modern oyuncak mağazası arayüzü
- ✅ 8 farklı oyuncak kategorisi
- ✅ Türkçe dil desteği
- ✅ Responsive tasarım
- ✅ Mock veri API'leri
- ✅ Sistem durum kontrolü

### Hedeflenen (Backend)

- 🎯 .NET 8 mikroservis mimarisi
- 🎯 Docker containerization
- 🎯 PostgreSQL, Redis, SQL Server veritabanları
- 🎯 RabbitMQ mesaj kuyruğu
- 🎯 CQRS, DDD, Event-Driven patterns
- 🎯 API Gateway (YARP)
- 🎯 gRPC iletişimi

## 🛠️ Gereksinimler

### Frontend İçin

- Node.js 16+
- npm veya yarn

### Backend İçin

- .NET 8 SDK
- Docker & Docker Compose
- Git

## 📚 Dokümantasyon

- `API_SORUN_COZUM_KILAVUZU.md` - API sorunları çözüm kılavuzu
- `PROJE_DETAYLI_DOKUMANTASYON.md` - Detaylı teknik dokümantasyon
- `CALISTIRMA_KILAVUZU.md` - Kurulum ve çalıştırma kılavuzu

## 📞 Destek

Sorun yaşıyorsanız:

1. `API_SORUN_COZUM_KILAVUZU.md` dosyasını kontrol edin
2. Health check endpoint'ini test edin: http://localhost:3000/api/health
3. Backend servislerinin çalışıp çalışmadığını kontrol edin

## 🎉 Çocukların Oyuncak Dünyasına Hoş Geldiniz!

Bu proje, çocuklar için güvenli ve eğlenceli alışveriş deneyimi sunan modern bir oyuncak mağazasıdır. LEGO'dan Barbie'ye, Hot Wheels'den eğitici oyuncaklara kadar geniş ürün yelpazesi ile çocukların hayal gücünü destekler.
