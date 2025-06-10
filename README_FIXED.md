# 🛒 EShop Microservices - Fixed & Enhanced

Bu proje, .NET 8.0 tabanlı modern bir e-ticaret mikroservis mimarisidir. **Tüm önemli hatalar düzeltilmiş** ve **geliştirilmiş UI** ile birlikte sunulmaktadır.

## 🔧 Düzeltilen Sorunlar

### ✅ Ana Problemler

- **502 Bad Gateway hatası** - Servis URL'leri ve port konfigürasyonları düzeltildi
- **Identity Service port çakışmaları** - Tutarlı port mappingleri yapıldı
- **API Gateway routing** - Doğru servis adresleri konfigüre edildi
- **Docker Compose konfigürasyonu** - Dependency management iyileştirildi
- **CORS politikaları** - Servisler arası iletişim düzeltildi

### 🎨 UI İyileştirmeleri

- **Responsive tasarım** - Mobil uyumlu interface
- **Geliştirilmiş navigation** - Kullanıcı dostu menü sistemi
- **Durum göstergeleri** - Servis bağlantı durumu bilgilendirmesi
- **Hata yönetimi** - Graceful error handling
- **Kullanıcı deneyimi** - Login/logout akışları iyileştirildi

## 🚀 Hızlı Başlangıç

### Gereksinimler

- Docker Desktop
- .NET 8.0 SDK (opsiyonel - sadece local development için)
- Git

### 1. Projeyi Klonlayın

```bash
git clone [repository-url]
cd eshop-microservices
```

### 2. Docker ile Başlatın

#### Windows (PowerShell):

```powershell
cd src
.\start-eshop.ps1
```

#### Linux/Mac:

```bash
cd src
chmod +x start-eshop.sh
./start-eshop.sh
```

#### Manuel Başlatma:

```bash
cd src
docker-compose down --remove-orphans
docker-compose build --no-cache
docker-compose up -d
```

## 🌐 Servis URL'leri

| Servis                  | URL                   | Açıklama             |
| ----------------------- | --------------------- | -------------------- |
| 🛒 **Shopping Web**     | http://localhost:6005 | Ana e-ticaret sitesi |
| 🔑 **Identity Service** | http://localhost:5000 | Kimlik doğrulama     |
| 🚪 **API Gateway**      | http://localhost:6004 | Gateway servisi      |
| 📦 **Catalog API**      | http://localhost:6000 | Ürün kataloğu        |
| 🛍️ **Basket API**       | http://localhost:6001 | Sepet yönetimi       |
| 📋 **Ordering API**     | http://localhost:6003 | Sipariş yönetimi     |
| 🎫 **Discount gRPC**    | http://localhost:6002 | İndirim servisi      |

### 🔧 Yönetim Panelleri

- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Redis**: localhost:6379

## 👤 Test Kullanıcıları

| Rol      | Email              | Şifre        | Açıklama           |
| -------- | ------------------ | ------------ | ------------------ |
| Admin    | admin@eshop.com    | Password123! | Yönetici yetkilerí |
| Customer | customer@eshop.com | Password123! | Normal kullanıcı   |

## 🏗️ Mimari Genel Bakış

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Shopping.Web  │────│  API Gateway    │────│   Identity API  │
│   (Frontend)    │    │   (YARP)        │    │ (IdentityServer)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                       ┌────────┼────────┐
                       │        │        │
              ┌────────▼──┐ ┌───▼───┐ ┌──▼────────���
              │Catalog API│ │Basket │ │Ordering   │
              │           │ │  API  │ │   API     │
              └────────▬──┘ └───▬───┘ └──▬────────┘
                       │        │        │
              ┌────────▼──┐ ┌───▼───┐ ┌──▼────────┐
              │PostgreSQL │ │ Redis │ │SQL Server │
              │ (Catalog) │ │(Cache)│ │(Orders)   │
              └───────────┘ └───────┘ └───────────┘
```

## 🔍 Sorun Giderme

### Servislerin Durumunu Kontrol Etme

```bash
docker-compose ps
```

### Log'ları İnceleme

```bash
# Tüm servislerin logları
docker-compose logs

# Belirli bir servisin logları
docker-compose logs identity.api
docker-compose logs shopping.web
docker-compose logs yarpapigateway
```

### Servisleri Yeniden Başlatma

```bash
# Tüm servisleri yeniden başlat
docker-compose restart

# Belirli bir servisi yeniden başlat
docker-compose restart shopping.web
```

### Temiz Başlangıç

```bash
docker-compose down --remove-orphans
docker-compose build --no-cache
docker-compose up -d
```

## 🐛 Bilinen Sorunlar ve Çözümleri

### 1. 502 Bad Gateway

**Durum**: Düzeltildi ✅

- API Gateway ve servis URL'leri düzeltildi
- Port konfigürasyonları tutarlı hale getirildi

### 2. Identity Service Connection Issues

**Durum**: Düzeltildi ✅

- CORS politikaları güncellendi
- Client redirect URL'leri düzeltildi

### 3. Service Discovery Issues

**Durum**: Düzeltildi ✅

- Docker network içi servis iletişimi optimize edildi
- Health check'ler eklendi

## 📚 Geliştirme

### Local Development Setup

```bash
# Identity Service
cd src/Services/Identity/Identity.API
dotnet run

# API Gateway
cd src/ApiGateways/YarpApiGateway
dotnet run

# Shopping Web
cd src/WebApps/Shopping.Web
dotnet run
```

### Environment Variables

| Variable                      | Development           | Production     |
| ----------------------------- | --------------------- | -------------- |
| ASPNETCORE_ENVIRONMENT        | Development           | Production     |
| ConnectionStrings\_\_Database | Local DB              | Production DB  |
| IdentityServer\_\_IssuerUri   | http://localhost:5000 | Production URL |

## 🔒 Güvenlik

- **IdentityServer4**: JWT token tabanlı authentication
- **HTTPS**: Production ortamında zorunlu
- **CORS**: Kısıtlı origin politikaları
- **Rate Limiting**: API Gateway'de aktif

## 📝 Changelog

### v2.0.0 (Fixed Version)

- ✅ 502 Bad Gateway hatası düzeltildi
- ✅ Identity Service port konfigürasyonları düzeltildi
- ✅ API Gateway routing yapılandırması iyileştirildi
- ✅ Docker Compose dependency management düzeltildi
- ✅ UI/UX iyileştirmeleri
- ✅ Comprehensive startup scripts eklendi
- ✅ Health checks eklendi
- ✅ Improved error handling

## 🤝 Katkıda Bulunma

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🆘 Destek

Sorun yaşıyorsanız:

1. Bu README'yi inceleyin
2. Issue tracker'da benzer sorunları arayın
3. Yeni bir issue açın
4. Docker logs'larını paylaşın

---

**Happy Shopping! 🛒✨**
