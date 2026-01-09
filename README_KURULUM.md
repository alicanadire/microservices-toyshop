# 🚀 EShop Mikroservices + IdentityServer4 - TEK KOMUT KURULUM

## 🎯 **Hızlı Başlangıç**

Tüm sistemi tek komutla çalıştırın:

```powershell
# PowerShell'i Administrator olarak çalıştırın
.\setup.ps1
```

**Hepsi bu kadar!** 🎉

---

## 📋 **Kurulum Seçenekleri**

### 1. **Otomatik Kurulum (Önerilen)**

```powershell
.\setup.ps1
```

- Önce Docker ile dener
- Başarısızsa otomatik olarak manuel kuruluma geçer
- Her şey otomatik!

### 2. **Manuel Kurulum**

```powershell
.\setup.ps1 -Manual
```

- Database'ler Docker container'da
- .NET servisleri manuel olarak
- Daha güvenilir

### 3. **Sadece Docker**

```powershell
.\setup.ps1 -DockerOnly
```

- Sadece Docker Compose kullanır
- Manuel kuruluma geçmez

### 4. **Zorla Devam Et**

```powershell
.\setup.ps1 -Force
```

- Hata varsa bile devam eder
- Eksik yazılım uyarılarını atlar

---

## 🎮 **Kullanım**

Kurulum tamamlandıktan sonra:

1. **🌐 Shopping Web'e git**: http://localhost:6005
2. **🛒 Cart veya Orders'a tıkla**
3. **🔐 Identity Service'e yönlendirileceksin**: https://localhost:5001
4. **👤 Test kullanıcılarıyla giriş yap**

---

## 🔑 **Test Kullanıcıları**

### **Admin Kullanıcı**

```
Email: admin@eshop.com
Şifre: Password123!
Rol: Admin
```

### **Müşteri Kullanıcı**

```
Email: customer@eshop.com
Şifre: Password123!
Rol: Customer
```

---

## 🌐 **Servis URL'leri**

| Servis               | URL                    | Açıklama                     |
| -------------------- | ---------------------- | ---------------------------- |
| **Shopping Web**     | http://localhost:6005  | Ana e-ticaret sitesi         |
| **Identity Service** | https://localhost:5001 | Kimlik doğrulama             |
| **API Gateway**      | http://localhost:6004  | Tüm API'lerin geçidi         |
| **Catalog API**      | http://localhost:6000  | Ürün servisi                 |
| **Basket API**       | http://localhost:6001  | Sepet servisi                |
| **Ordering API**     | http://localhost:6003  | Sipariş servisi              |
| **RabbitMQ**         | http://localhost:15672 | Message broker (guest/guest) |

---

## ✅ **Gereksinimler**

### **Otomatik kontrol edilir:**

- ✅ .NET 8.0 SDK
- ✅ Docker Desktop (opsiyonel)
- ✅ Administrator yetkileri

### **İndirme Linkleri:**

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)

---

## 🔧 **Sorun Giderme**

### **Port Çakışması**

```powershell
# Kullanılan portları kontrol et
netstat -ano | findstr :5001
netstat -ano | findstr :6005

# İşlemi sonlandır
taskkill /PID <PID_NUMARASI> /F
```

### **Docker Sorunları**

```powershell
# Docker'ı temizle
docker system prune -f
docker-compose down --remove-orphans

# Manuel kuruluma geç
.\setup.ps1 -Manual
```

### **SSL Sertifika Sorunları**

```powershell
# Sertifikaları yenile
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

---

## 🎯 **Sistem Özellikleri**

### **🔐 Kimlik Doğrulama**

- **IdentityServer4** (Duende)
- **OpenID Connect** flow
- **JWT Token** tabanlı API güvenliği
- **Role-based authorization**

### **🏗️ Mikroservis Mimarisi**

- **API Gateway** (YARP)
- **Message Broker** (RabbitMQ)
- **Distributed Cache** (Redis)
- **Multiple Databases** (PostgreSQL, SQL Server)

### **🌐 Web Teknolojileri**

- **ASP.NET Core 8.0**
- **Razor Pages**
- **Bootstrap 5**
- **Font Awesome**

---

## 💡 **İpuçları**

1. **🔄 Yeniden başlat**: Sadece `.\setup.ps1` çalıştır
2. **📊 Durum kontrol**: `docker-compose ps` (Docker modunda)
3. **📝 Loglar**: `docker-compose logs` (Docker modunda)
4. **🛑 Durdur**: `docker-compose down` (Docker modunda)

---

## 🎉 **Başarı Göstergeleri**

Kurulum başarılı olduğunda:

✅ Shopping Web açılır: http://localhost:6005  
✅ Identity Service çalışır: https://localhost:5001  
✅ Giriş yapmaya yönlendirme çalışır  
✅ Test kullanıcılarıyla giriş yapılabilir  
✅ Cart ve Orders sayfaları korunur

---

## 📞 **Destek**

Sorun yaşarsan:

1. **PowerShell'i Administrator olarak çalıştır**
2. **Docker Desktop'ın çalıştığından emin ol**
3. **Antivirus/Firewall kontrolü yap**
4. **Alternatif kurulum modlarını dene**

**🚀 Tek komutla tamamen çalışan e-ticaret sistemi!**
