# ToyShop API Sorunları Çözüm Kılavuzu

## ✅ Şu An Çalışan Sistem

**Node.js Development Server** (Port 3000) ✅

- Frontend arayüzü çalışıyor
- Mock data API'leri çalışıyor
- Health check endpoint çalışıyor

## ❌ Sorun Yaşanan Sistem

**.NET Mikroservisler** (Portlar 6000-6005) ❌

- Backend servisleri çalışmıyor
- API Gateway çalışmıyor
- Veritabanları çalışmıyor

## 🔧 Sorunu Çözme Adımları

### 1. Backend Servislerini Başlatma

#### Option A: Docker ile Tam Kurulum

```bash
cd src
docker-compose up -d
```

#### Option B: Manuel .NET Servisleri

```bash
# Terminal 1 - Catalog Service
cd src/Services/Catalog/Catalog.API
dotnet run

# Terminal 2 - Basket Service
cd src/Services/Basket/Basket.API
dotnet run

# Terminal 3 - Ordering Service
cd src/Services/Ordering/Ordering.API
dotnet run

# Terminal 4 - API Gateway
cd src/ApiGateways/YarpApiGateway
dotnet run

# Terminal 5 - Shopping Web
cd src/WebApps/Shopping.Web
dotnet run
```

### 2. Servis Durumunu Kontrol Etme

#### Frontend Health Check

```bash
curl http://localhost:3000/api/health
```

#### Backend Servisleri Kontrol

```bash
# API Gateway
curl https://localhost:6064/health

# Catalog Service
curl http://localhost:6000/health

# Basket Service
curl http://localhost:6001/health

# Ordering Service
curl http://localhost:6003/health
```

### 3. Yaygın Sorunlar ve Çözümleri

#### Sorun: "Backend services not available"

```bash
# Portları kontrol et
netstat -tulpn | grep :600[0-9]

# Docker container'ları kontrol et
docker ps

# .NET SDK kurulu mu kontrol et
dotnet --version
```

#### Sorun: "HTTPS certificate errors"

```bash
# Development certificates'i güven
dotnet dev-certs https --trust
```

#### Sorun: "Database connection errors"

```bash
# Docker veritabanlarını kontrol et
docker ps | grep postgres
docker ps | grep sql
docker ps | grep redis
```

## 🌐 URL Mapping

### Frontend (Node.js)

- **Ana Sayfa**: http://localhost:3000/
- **Ürünler**: http://localhost:3000/products
- **Sepet**: http://localhost:3000/cart
- **Siparişler**: http://localhost:3000/orders
- **Health Check**: http://localhost:3000/api/health

### Backend (.NET)

- **Shopping Web**: https://localhost:6065
- **API Gateway**: https://localhost:6064
- **Catalog API**: http://localhost:6000
- **Basket API**: http://localhost:6001
- **Discount gRPC**: http://localhost:6002
- **Ordering API**: http://localhost:6003

## 📋 Sistem Durumu Indikasyonu

### Frontend'de Durum Gösterimi

- ✅ **Yeşil**: Backend aktif, canlı veriler
- ⚠️ **Sarı**: Mock veri modu, backend kullanılamıyor
- ❌ **Kırmızı**: Frontend çalışmıyor

### Health Check Response

```json
{
  "status": "degraded",
  "services": {
    "frontend": true,
    "gateway": false,
    "catalog": false,
    "basket": false,
    "ordering": false
  },
  "timestamp": "2024-06-10T23:05:52.322Z",
  "mode": "mock"
}
```

## 🚀 Hızlı Başlatma

### Development Ortamı (Mock Data)

```bash
npm run dev
# http://localhost:3000 açılır, mock data kullanır
```

### Production Ortamı (Full Backend)

```bash
# 1. Backend'i başlat
cd src && docker-compose up -d

# 2. Frontend'i başlat
npm run dev

# 3. Tam uygulama
# https://localhost:6065 açılır
```

## 🔍 Debug Adımları

1. **Frontend çalışıyor mu?** → http://localhost:3000
2. **Health check çalışıyor mu?** → http://localhost:3000/api/health
3. **Docker çalışıyor mu?** → `docker ps`
4. **Portlar açık mı?** → `netstat -tulpn | grep :600[0-9]`
5. **.NET SDK kurulu mu?** → `dotnet --version`

## 📞 Destek

Eğer sorunlar devam ederse:

1. Logları kontrol edin: `docker-compose logs`
2. Port çakışmalarını kontrol edin
3. Firewall ayarlarını kontrol edin
4. Admin yetkileriyle çalıştırmayı deneyin
