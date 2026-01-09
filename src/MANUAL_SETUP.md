# 🔥 MANUAL HTTP-ONLY SETUP - DOCKER SORUNLARI OLMADAN

## 🚨 Docker Build Sorunları mı? Bu çözüm!

Docker build hatalarından kurtulmak için manuel HTTP-only kurulum:

### 🚀 TEK KOMUT:

```powershell
cd src
.\emergency-fix.ps1
```

### 📋 Manuel Adım Adım:

#### 1. Database'leri Docker'da Başlat:

```bash
# PostgreSQL for Identity
docker run -d --name identitydb -p 5434:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=IdentityDb postgres

# PostgreSQL for Catalog
docker run -d --name catalogdb -p 5432:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=CatalogDb postgres

# PostgreSQL for Basket
docker run -d --name basketdb -p 5433:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=BasketDb postgres

# SQL Server for Orders
docker run -d --name orderdb -p 1433:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=SwN12345678" mcr.microsoft.com/mssql/server:2022-latest

# Redis
docker run -d --name redis -p 6379:6379 redis

# RabbitMQ
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest rabbitmq:management
```

#### 2. .NET Servisleri Manuel Başlat:

**Terminal 1 - Identity Service:**

```bash
cd Services/Identity/Identity.API
$env:ASPNETCORE_URLS="http://localhost:5000"
dotnet run
```

**Terminal 2 - API Gateway:**

```bash
cd ApiGateways/YarpApiGateway
$env:ASPNETCORE_URLS="http://localhost:6004"
dotnet run
```

**Terminal 3 - Shopping Web:**

```bash
cd WebApps/Shopping.Web
$env:ASPNETCORE_URLS="http://localhost:6005"
dotnet run
```

**Terminal 4 - Catalog API:**

```bash
cd Services/Catalog/Catalog.API
$env:ASPNETCORE_URLS="http://localhost:6000"
dotnet run
```

**Terminal 5 - Basket API:**

```bash
cd Services/Basket/Basket.API
$env:ASPNETCORE_URLS="http://localhost:6001"
dotnet run
```

**Terminal 6 - Ordering API:**

```bash
cd Services/Ordering/Ordering.API
$env:ASPNETCORE_URLS="http://localhost:6003"
dotnet run
```

### 🌐 HTTP Erişim:

| Servis               | HTTP URL               |
| -------------------- | ---------------------- |
| **Shopping Web**     | http://localhost:6005  |
| **Identity Service** | http://localhost:5000  |
| **API Gateway**      | http://localhost:6004  |
| **Catalog API**      | http://localhost:6000  |
| **Basket API**       | http://localhost:6001  |
| **Ordering API**     | http://localhost:6003  |
| **RabbitMQ**         | http://localhost:15672 |

### 🔑 Test:

1. **http://localhost:6005** → Shopping Web
2. **Cart/Orders tıkla**
3. **http://localhost:5000** → Identity'e yönlendir
4. **admin@eshop.com / Password123!** ile giriş

### ✅ Avantajlar:

- ❌ Docker build hatası YOK
- ❌ SSL karışıklığı YOK
- ❌ HTTPS sertifika sorunu YOK
- ✅ Sadece temiz HTTP
- ✅ Her servis ayrı terminal'de debug edilebilir
- ✅ Hızlı restart edilebilir

### 🛑 Servisleri Durdur:

```bash
# Database'leri durdur
docker stop identitydb catalogdb basketdb orderdb redis rabbitmq
docker rm identitydb catalogdb basketdb orderdb redis rabbitmq

# .NET servisleri: Ctrl+C ile durdur her terminalde
```

**🚀 Docker sorunları olmadan çalışan sistem!**
