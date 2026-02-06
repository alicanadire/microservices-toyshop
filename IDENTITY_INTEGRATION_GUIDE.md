# EShop Identity Integration Guide

Bu rehber, EShop mikroservis projesine IdentityServer4 tabanlı kimlik doğrulama sisteminin nasıl entegre edildiğini açıklar.

## 🎯 Eklenen Özellikler

### ✅ Identity Service (Kimlik Servisi)

- **Duende IdentityServer 6.3** tabanlı merkezi kimlik doğrulama
- **ASP.NET Core Identity** ile kullanıcı yönetimi
- **OAuth 2.0 / OpenID Connect** protokolleri
- **JWT Token** tabanlı API güvenliği
- Modern, responsive kullanıcı arayüzü

### ✅ Kullanıcı Yönetimi

- Kullanıcı kaydı ve giriş sayfaları
- Profil yönetimi
- Rol tabanlı yetkilendirme (Admin, Customer)
- "Beni Hatırla" özelliği

### ✅ API Gateway Entegrasyonu

- JWT token doğrulama
- Mikroservislere güvenli erişim
- Rate limiting ile korumalı endpoints

### ✅ Shopping Web Entegrasyonu

- OpenID Connect authentication
- Automatic token refresh
- Protected pages (Cart, Checkout, Orders)
- User profile ve logout özelliği

## 📁 Yeni Dosya Yapısı

```
src/
├── Services/
│   └── Identity/Identity.API/
│       ├── Controllers/
│       │   ├── AccountController.cs
│       │   └── HomeController.cs
│       ├── Data/
│       │   └── IdentityDbContext.cs
│       ├── Models/
│       │   └── ApplicationUser.cs
│       ├── Services/
│       │   └── ProfileService.cs
│       ├── ViewModels/
│       │   ├── LoginViewModel.cs
│       │   └── RegisterViewModel.cs
│       ├── Views/
│       │   ├── Account/
│       │   │   ├── Login.cshtml
│       │   │   └── Register.cshtml
│       │   ├── Home/
│       │   │   └── Index.cshtml
│       │   └── Shared/
│       │       └── _Layout.cshtml
│       └── Configuration/
│           └── IdentityServerConfig.cs
│
└── WebApps/Shopping.Web/
    ├── Pages/Account/
    │   ├── Login.cshtml
    │   ├── Register.cshtml
    │   ├── Profile.cshtml
    │   ├── Logout.cshtml
    │   └── AccessDenied.cshtml
    ├── Models/Identity/
    │   └── UserViewModel.cs
    └── Services/
        └── AuthenticationDelegatingHandler.cs
```

## 🔧 Yapılandırma

### Identity Service Ports

- **Development**: https://localhost:5001, http://localhost:5000
- **Docker**: http://identity.api:8080

### Test Kullanıcıları

#### Admin Kullanıcı

```
Email: admin@eshop.com
Şifre: Password123!
Rol: Admin
```

#### Müşteri Kullanıcı

```
Email: customer@eshop.com
Şifre: Password123!
Rol: Customer
```

## 🚀 Çalıştırma Talimatları

### 1. Identity Service'i Çalıştırın

```bash
cd src/Services/Identity/Identity.API
dotnet run
```

### 2. API Gateway'i Çalıştırın

```bash
cd src/ApiGateways/YarpApiGateway
dotnet run
```

### 3. Shopping Web'i Çalıştırın

```bash
cd src/WebApps/Shopping.Web
dotnet run
```

### 4. Diğer Mikroservisleri Çalıştırın

```bash
# Catalog Service
cd src/Services/Catalog/Catalog.API
dotnet run

# Basket Service
cd src/Services/Basket/Basket.API
dotnet run

# Ordering Service
cd src/Services/Ordering/Ordering.API
dotnet run
```

## 🔐 Güvenlik Özellikleri

### Authentication Flow

1. Kullanıcı Shopping Web'e giriş yapmaya çalışır
2. OpenID Connect ile Identity Service'e yönlendirilir
3. Başarılı giriş sonrası JWT token alır
4. Token, API Gateway üzerinden mikroservislere erişim sağlar

### Authorization

- **Anonymous**: Index, ProductList sayfaları
- **Authenticated**: Cart, Checkout, OrderList sayfaları
- **Admin Role**: Gelecekte admin paneli için

### Token Management

- Access Token: 1 saat geçerli
- Refresh Token: 30 gün geçerli
- Automatic token renewal

## 🌐 API Endpoints

### Identity Service

- `GET /.well-known/openid_configuration` - Discovery endpoint
- `POST /connect/token` - Token endpoint
- `GET /connect/userinfo` - User info endpoint
- `GET /Account/Login` - Login page
- `GET /Account/Register` - Register page

### API Gateway Routes

- `/identity-service/*` → Identity Service
- `/catalog-service/*` → Catalog Service (Protected)
- `/basket-service/*` → Basket Service (Protected)
- `/ordering-service/*` → Ordering Service (Protected)

## 🎨 UI Özellikleri

### Identity Service UI

- Modern gradient design
- Bootstrap 5 responsive layout
- Font Awesome icons
- Smooth animations ve transitions

### Shopping Web UI

- Updated navigation with user menu
- Login/Register buttons for anonymous users
- User dropdown with profile/logout options
- Protected page redirections

## 🔄 Next Steps

### Production Hazırlığı

1. **Persistent Database**: In-memory yerine SQL Server/PostgreSQL
2. **Certificate Management**: Production signing certificates
3. **HTTPS Configuration**: SSL certificates
4. **Environment Configuration**: Production settings
5. **Monitoring**: Logging ve health checks

### Gelişmiş Özellikler

1. **Two-Factor Authentication**: SMS/Email verification
2. **Social Login**: Google, Facebook, Microsoft
3. **Password Reset**: Email-based password recovery
4. **Account Lockout**: Brute force protection
5. **Admin Panel**: User management interface

## 🐛 Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure proper redirect URIs in IdentityServerConfig
2. **Token Validation**: Check Authority URLs match between services
3. **HTTPS Issues**: Configure proper certificates or disable HTTPS metadata
4. **Database Issues**: Ensure Entity Framework migrations are applied

### Debug Mode

Set following in appsettings.Development.json:

```json
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore.Authentication": "Debug",
      "IdentityServer": "Debug"
    }
  }
}
```

Bu entegrasyon sayesinde EShop projesi artık tam bir kullanıcı kimlik doğrulama ve yetkilendirme sistemine sahip! 🎉
