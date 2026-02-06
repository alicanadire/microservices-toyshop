# 🚀 EShop Mikroservices - HTTP-ONLY TEK KOMUT KURULUM

## 🎯 **Hızlı Başlangıç (HTTP - SSL YOK!)**

Tüm sistemi tek komutla HTTP-only çalıştırın:

```powershell
# PowerShell'i Administrator olarak çalıştırın
cd src
.\setup-http.ps1
```

**🔥 HTTPS karışıklığı olmadan, sadece HTTP! 🔥**

---

## 🌐 **HTTP Servis URL'leri**

| Servis               | HTTP URL               | Açıklama                     |
| -------------------- | ---------------------- | ---------------------------- |
| **Shopping Web**     | http://localhost:6005  | Ana e-ticaret sitesi         |
| **Identity Service** | http://localhost:5000  | Kimlik doğrulama (HTTP!)     |
| **API Gateway**      | http://localhost:6004  | Tüm API'lerin geçidi         |
| **Catalog API**      | http://localhost:6000  | Ürün servisi                 |
| **Basket API**       | http://localhost:6001  | Sepet servisi                |
| **Ordering API**     | http://localhost:6003  | Sipariş servisi              |
| **RabbitMQ**         | http://localhost:15672 | Message broker (guest/guest) |

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

## 🎮 **Kullanım**

1. **🌐 Shopping Web'e git**: http://localhost:6005
2. **🛒 Cart veya Orders'a tıkla**
3. **🔐 Identity Service'e yönlendirileceksin**: http://localhost:5000
4. **👤 Test kullanıcılarıyla giriş yap**

**❌ SSL sertifika hatası YOK!**  
**❌ HTTPS karışıklığı YOK!**  
**✅ Sadece temiz HTTP!**

---

## ✅ **HTTP-Only Avantajları**

- 🚫 **SSL sertifika hatası yok**
- 🚫 **HTTPS karışıklığı yok**
- 🚫 **Certificate trust problemi yok**
- ✅ **Daha hızlı kurulum**
- ✅ **Daha az hata**
- ✅ **Development için ideal**

---

## 🔧 **Hızlı Sorun Giderme**

### **Port Çakışması**

```powershell
# Kullanılan HTTP portları kontrol et
netstat -ano | findstr :5000
netstat -ano | findstr :6005

# İşlemi sonlandır
taskkill /PID <PID_NUMARASI> /F
```

### **Docker Temizleme**

```powershell
# HTTP-only yeniden başlat
cd src
docker-compose down --remove-orphans
.\setup-http.ps1
```

### **Manuel HTTP Başlatma**

```powershell
cd src

# Temizlik
docker-compose down --remove-orphans
docker builder prune -f

# HTTP-only build
docker-compose build --no-cache
docker-compose up -d

# HTTP kontrol
curl http://localhost:5000
curl http://localhost:6005
```

---

## 🎯 **HTTP Sistem Özellikleri**

### **🔐 HTTP Kimlik Doğrulama**

- **IdentityServer4** HTTP mode
- **OpenID Connect** HTTP flow
- **JWT Token** HTTP-only
- **No SSL required**

### **🏗️ HTTP Mikroservis Mimarisi**

- **API Gateway** HTTP-only
- **All services** HTTP communication
- **No certificate issues**
- **Clean HTTP routing**

---

## 💡 **HTTP-Only İpuçları**

1. **🔄 Yeniden başlat**: `.\setup-http.ps1`
2. **📊 Durum kontrol**: `docker-compose ps`
3. **📝 HTTP Loglar**: `docker-compose logs`
4. **🛑 Durdur**: `docker-compose down`

---

## 🎉 **HTTP Başarı Göstergeleri**

✅ Shopping Web HTTP açılır: http://localhost:6005  
✅ Identity Service HTTP çalışır: http://localhost:5000  
✅ HTTP giriş yönlendirme çalışır  
✅ Test kullanıcılarıyla HTTP giriş  
✅ Cart ve Orders HTTP korunur

**🚫 SSL hatası YOK!**  
**🚫 Certificate problemi YOK!**  
**✅ Sadece temiz HTTP çalışır!**

---

## 🔥 **Neden HTTP-Only?**

- **Development için daha kolay**
- **SSL certificate karışıklığı yok**
- **Tarayıcı güvenlik uyarıları yok**
- **Daha hızlı ve stabil**
- **Production'da HTTPS ekleyebilirsin**

**🚀 Tek komutla tamamen HTTP çalışan e-ticaret sistemi!**
