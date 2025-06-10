# 🧸 ToyShop - Kapsamlı Teknik Dokümantasyon

## 📋 İçindekiler

1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Mimari Yapı](#mimari-yapı)
3. [Teknolojiler](#teknolojiler)
4. [Dosya Yapısı](#dosya-yapısı)
5. [Mikroservisler](#mikroservisler)
6. [Frontend Yapısı](#frontend-yapısı)
7. [Veritabanları](#veritabanları)
8. [API Gateway](#api-gateway)
9. [Messaging](#messaging)
10. [Güvenlik](#güvenlik)
11. [DevOps](#devops)
12. [Kod Akışı](#kod-akışı)

---

## 🎯 Proje Genel Bakış

### Nedir?

**ToyShop**, modern mikroservis mimarisi ile geliştirilmiş kapsamlı bir e-ticaret platformudur. Özellikle oyuncak satışı için optimize edilmiş olup, çocuk dostu arayüz ve güvenli alışveriş deneyimi sunar.

### Teknik Seviye

- **Enterprise-level** mikroservis mimarisi
- **Domain-Driven Design (DDD)** yaklaşımı
- **CQRS + Event Sourcing** pattern'leri
- **Clean Architecture** prensipleri
- **Cloud-Ready** containerized deployment

### İş Gereksinimleri

- Oyuncak kategorilerinde ürün katalog yönetimi
- Gerçek zamanlı stok takibi
- Sepet yönetimi ve sipariş işleme
- İndirim kuponları sistemi
- Kullanıcı dostu modern arayüz
- Mobil uyumlu responsive tasarım

---

## 🏗️ Mimari Yapı

### Mikroservis Mimarisi

```
┌─────────────────────────────────────────────────┐
│                 Client Layer                    │
├─────────────────────────────────────────────────┤
│     Shopping.Web (ASP.NET Core Razor Pages)    │
├─────────────────────────────────────────────────┤
│              API Gateway (YARP)                 │
├─────────────────────────────────────────────────┤
│                Microservices                    │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │Catalog  │ │ Basket  │ │Discount │ │Ordering ││
│  │   API   │ │   API   │ │  gRPC   │ │   API   ││
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘│
├─────────────────────────────────────────────────┤
│                  Data Layer                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │PostgreSQL│ │ Redis   │ │ SQLite  │ │SQL Server│
│  │(Catalog) │ │(Basket) │ │(Discount│ │(Ordering│
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘│
├─────────────────────────────────────────────────┤
│            Message Broker (RabbitMQ)            │
└─────────────────────────────────────────────────┘
```

### Architecture Patterns

1. **Mikroservis Architecture**

   - Service Independence
   - Database per Service
   - Decentralized Data Management

2. **Domain-Driven Design (DDD)**

   - Bounded Contexts
   - Aggregates
   - Domain Events
   - Value Objects

3. **CQRS (Command Query Responsibility Segregation)**

   - Read/Write ayrımı
   - Command Handlers
   - Query Handlers

4. **Event-Driven Architecture**
   - Domain Events
   - Integration Events
   - Event Sourcing

---

## 💻 Teknolojiler

### Backend Stack

```yaml
Framework: .NET 8
Language: C# 12
Architecture: Clean Architecture + Onion Architecture

Libraries:
  - ASP.NET Core 8 (Web API)
  - Entity Framework Core 8 (ORM)
  - MediatR (CQRS implementation)
  - FluentValidation (Input validation)
  - Marten (Document DB for PostgreSQL)
  - MassTransit (Message bus)
  - YARP (Reverse proxy)
  - Carter (Minimal APIs)
  - Refit (HTTP client)
  - Polly (Resilience patterns)
```

### Frontend Stack

```yaml
Primary: ASP.NET Core Razor Pages
Preview: Node.js + Express

CSS Framework: Bootstrap 5.3
Icons: Font Awesome 6.4
Fonts: Google Fonts (Nunito)
JavaScript: Vanilla JS + jQuery
Responsive: Mobile-first design

Development Preview:
  - Node.js server
  - Modern CSS Grid/Flexbox
  - Gradient backgrounds
  - Smooth animations
  - Interactive components
```

### Database Technologies

```yaml
Catalog Service: PostgreSQL (Document store via Marten)
Basket Service: Redis (In-memory cache)
Discount Service: SQLite (Lightweight relational)
Ordering Service: SQL Server (Complex relational)

Features:
  - Database per service
  - Polyglot persistence
  - Data consistency patterns
  - Migration strategies
```

### Infrastructure

```yaml
Containerization: Docker + Docker Compose
Message Broker: RabbitMQ
API Gateway: YARP (Yet Another Reverse Proxy)
Monitoring: Built-in logging
Security: HTTPS, CORS, Authentication ready
```

---

## 📁 Dosya Yapısı Detayı

### Root Level

```
toyshop-microservices/
├── src/                          # Ana kaynak kodlar
├── package.json                  # Node.js bağımlılıkları
├── server.js                     # Development preview server
├── setup.ps1                     # Windows otomatik kurulum
├── CALISTIRMA_KILAVUZU.md       # Kurulum rehberi
└── README.md                     # Proje açıklaması
```

### Source Code Structure

```
src/
├── ApiGateways/
│   └── YarpApiGateway/           # API Gateway servisi
├── BuildingBlocks/               # Paylaşılan kütüphaneler
│   ├── BuildingBlocks/           # Temel abstraksiyonlar
│   └── BuildingBlocks.Messaging/ # Event/Message handling
├── Services/                     # Mikroservisler
│   ├── Catalog/Catalog.API/      # Ürün katalog servisi
│   ├── Basket/Basket.API/        # Sepet yönetimi servisi
│   ├── Discount/Discount.Grpc/   # İndirim servisi (gRPC)
│   └── Ordering/                 # Sipariş servisi (DDD)
│       ├── Ordering.API/         # API katmanı
│       ├── Ordering.Application/ # Uygulama katmanı
│       ├── Ordering.Domain/      # Domain katmanı
│       └── Ordering.Infrastructure/ # Infrastructure katmanı
├── WebApps/
│   └── Shopping.Web/             # Web uygulaması
├── docker-compose.yml            # Servis orchestration
└── eshop-microservices.sln      # .NET solution dosyası
```

---

## 🛍️ Mikroservisler Detayı

### 1. Catalog.API (Ürün Kataloğu)

```csharp
// Teknolojiler
- ASP.NET Core Web API
- Marten (PostgreSQL Document DB)
- Carter (Minimal APIs)

// Sorumluluklar
- Ürün CRUD işlemleri
- Kategori yönetimi
- Ürün arama ve filtreleme
- Fiyat güncelleme

// Endpoints
GET    /products                 # Tüm ürünler
GET    /products/{id}            # Ürün detayı
GET    /products/category/{cat}  # Kategoriye göre ürünler
POST   /products                 # Yeni ürün
PUT    /products/{id}            # Ürün güncelleme
DELETE /products/{id}            # Ürün silme

// Database Schema (Document)
{
  "Id": "guid",
  "Name": "string",
  "Description": "string",
  "ImageFile": "string",
  "Price": "decimal",
  "Category": ["string"]
}
```

### 2. Basket.API (Sepet Yönetimi)

```csharp
// Teknolojiler
- ASP.NET Core Web API
- Redis (In-memory storage)
- Decorator Pattern (Caching)

// Sorumluluklar
- Sepet oluşturma ve yönetimi
- Ürün ekleme/çıkarma
- Sepet toplam hesaplama
- Sipariş öncesi hazırlık

// Endpoints
GET    /basket/{username}        # Sepeti getir
POST   /basket                   # Sepet oluştur/güncelle
DELETE /basket/{username}        # Sepeti sil
POST   /basket/checkout          # Checkout işlemi

// Data Model
{
  "UserName": "string",
  "Items": [
    {
      "ProductId": "guid",
      "ProductName": "string",
      "Price": "decimal",
      "Quantity": "int",
      "Color": "string"
    }
  ],
  "TotalPrice": "decimal"
}
```

### 3. Discount.Grpc (İndirim Servisi)

```csharp
// Teknolojiler
- gRPC (High-performance RPC)
- Entity Framework Core
- SQLite Database

// Sorumluluklar
- İndirim kuponları yönetimi
- Ürün bazlı indirimler
- Validation rules
- Performance optimizations

// gRPC Services
rpc GetDiscount(GetDiscountRequest) returns (CouponModel);
rpc CreateDiscount(CreateDiscountRequest) returns (CouponModel);
rpc UpdateDiscount(UpdateDiscountRequest) returns (CouponModel);
rpc DeleteDiscount(DeleteDiscountRequest) returns (DeleteDiscountResponse);

// Proto Definition
message CouponModel {
  int32 Id = 1;
  string ProductName = 2;
  string Description = 3;
  int32 Amount = 4;
}
```

### 4. Ordering (Sipariş Servisi - DDD Implementation)

```csharp
// Teknolojiler
- Clean Architecture
- Domain-Driven Design
- CQRS + MediatR
- Entity Framework Core + SQL Server
- Domain Events

// Katmanlar
Domain/          # Pure business logic
├── Entities/    # Order, Customer, Product
├── ValueObjects/# Address, Payment, Money
├── Events/      # OrderCreated, OrderUpdated
└── Aggregates/  # Order Aggregate

Application/     # Use cases
├── Commands/    # CreateOrder, UpdateOrder
├── Queries/     # GetOrders, GetOrdersByCustomer
├── Handlers/    # Command/Query handlers
└── Events/      # Event handlers

Infrastructure/  # External concerns
├── Data/        # EF Context, Repositories
├── Messaging/   # Event publishing
└── Services/    # External service calls

API/             # HTTP endpoints
├── Endpoints/   # REST API endpoints
└── Controllers/ # API controllers
```

---

## 🌐 Frontend Yapısı

### Development Preview (Node.js)

```javascript
// server.js - Express.js Server
const express = require('express');
const app = express();

// Modern Oyuncak Data
const mockProducts = [
  {
    id: 1,
    name: 'LEGO Creator Expert 🏠',
    category: 'Building Sets',
    description: 'Amazing building experience...',
    price: 89.99,
    ageRange: '12+',
    brand: 'LEGO'
  }
  // ... 8 different toy categories
];

// Route Structure
GET /           # Ana sayfa (Hero + Categories + Products)
GET /products   # Ürün listesi (Filters + Grid + Search)
GET /products/:id # Ürün detayı (Images + Info + Reviews)
GET /cart       # Sepet (Items + Summary + Checkout)
GET /orders     # Siparişler (History + Tracking)
GET /contact    # İletişim (Form + Info + FAQ)
```

### Production Web App (ASP.NET Core)

```csharp
// Pages Structure
Pages/
├── Index.cshtml              # Ana sayfa
├── ProductList.cshtml        # Ürün listesi
├── ProductDetail.cshtml      # Ürün detayı
├── Cart.cshtml              # Sepet
├── Checkout.cshtml          # Ödeme
├── OrderList.cshtml         # Siparişler
├── Contact.cshtml           # İletişim
└── Shared/
    ├── _Layout.cshtml       # Master layout
    ├── _ProductItemPartial.cshtml  # Ürün kartı
    └── _TopProductPartial.cshtml   # Öne çıkan ürün

// Models
Models/
├── Catalog/
│   └── ProductModel.cs      # Ürün veri modeli
├── Basket/
│   └── ShoppingCartModel.cs # Sepet modeli
└── Ordering/
    └── OrderModel.cs        # Sipariş modeli

// Services (HTTP Clients)
Services/
├── ICatalogService.cs       # Catalog API client
├── IBasketService.cs        # Basket API client
└── IOrderingService.cs      # Ordering API client
```

### Modern CSS/UI Features

```css
/* CSS Variables */
:root {
  --primary-color: #FF6B6B;    /* Coral red */
  --secondary-color: #4ECDC4;  /* Mint green */
  --accent-color: #FFE66D;     /* Warm yellow */
  --purple-color: #A8E6CF;     /* Light green */
  --pink-color: #FFB3BA;       /* Light pink */
  --blue-color: #BFEFFF;       /* Light blue */
}

/* Modern Features */
- CSS Grid & Flexbox layouts
- Gradient backgrounds
- Border radius (20px everywhere)
- Box shadows for depth
- Smooth transitions (0.3s ease)
- Hover animations (translateY(-10px))
- Responsive breakpoints
- Mobile-first approach
```

---

## 🗄️ Veritabanları

### 1. PostgreSQL (Catalog Service)

```sql
-- Marten Document Store
-- JSON documents stored as JSONB

Products Collection:
{
  "Id": "5334c996-8457-4cf0-815c-ed2b77c4ff61",
  "Name": "LEGO Creator Expert Evi",
  "Description": "Bu harika LEGO seti...",
  "ImageFile": "lego-house.jpg",
  "Price": 89.99,
  "Category": ["Yapı Setleri"]
}

-- Indexes
CREATE INDEX idx_products_category ON products USING GIN ((data->'Category'));
CREATE INDEX idx_products_price ON products USING BTREE ((data->>'Price')::decimal);
```

### 2. Redis (Basket Service)

```redis
# Key-Value Store
# Pattern: basket:{username}

SET basket:ahmet '{
  "UserName": "ahmet",
  "Items": [
    {
      "ProductId": "5334c996-8457-4cf0-815c-ed2b77c4ff61",
      "ProductName": "LEGO Creator Expert",
      "Price": 89.99,
      "Quantity": 2
    }
  ],
  "TotalPrice": 179.98
}'

# TTL (Time To Live)
EXPIRE basket:ahmet 86400  # 24 hours
```

### 3. SQLite (Discount Service)

```sql
-- Relational Database
CREATE TABLE Coupons (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    ProductName TEXT NOT NULL,
    Description TEXT NOT NULL,
    Amount INTEGER NOT NULL
);

-- Seed Data
INSERT INTO Coupons VALUES
(1, 'LEGO Creator Expert Evi', 'LEGO Oyuncakları İndirimi', 20),
(2, 'Barbie Dreamhouse', 'Barbie Bebek İndirimi', 30);
```

### 4. SQL Server (Ordering Service)

```sql
-- Relational Database with DDD approach
-- Aggregate Tables

-- Customers Table
CREATE TABLE Customers (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL
);

-- Orders Table (Aggregate Root)
CREATE TABLE Orders (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    CustomerId UNIQUEIDENTIFIER NOT NULL,
    OrderName NVARCHAR(100) NOT NULL,
    ShippingAddress_FirstName NVARCHAR(50),
    ShippingAddress_LastName NVARCHAR(50),
    ShippingAddress_EmailAddress NVARCHAR(255),
    ShippingAddress_AddressLine NVARCHAR(255),
    ShippingAddress_Country NVARCHAR(50),
    ShippingAddress_State NVARCHAR(50),
    ShippingAddress_ZipCode NVARCHAR(10),
    BillingAddress_FirstName NVARCHAR(50),
    BillingAddress_LastName NVARCHAR(50),
    BillingAddress_EmailAddress NVARCHAR(255),
    BillingAddress_AddressLine NVARCHAR(255),
    BillingAddress_Country NVARCHAR(50),
    BillingAddress_State NVARCHAR(50),
    BillingAddress_ZipCode NVARCHAR(10),
    Payment_CardName NVARCHAR(50),
    Payment_CardNumber NVARCHAR(24),
    Payment_Expiration NVARCHAR(10),
    Payment_CVV NVARCHAR(3),
    Payment_PaymentMethod INTEGER,
    Status INTEGER NOT NULL,
    TotalPrice DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME2 NOT NULL,
    CreatedBy NVARCHAR(50),
    LastModified DATETIME2,
    LastModifiedBy NVARCHAR(50),
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id)
);

-- Order Items Table
CREATE TABLE OrderItems (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    OrderId UNIQUEIDENTIFIER NOT NULL,
    ProductId UNIQUEIDENTIFIER NOT NULL,
    Quantity INTEGER NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(Id)
);

-- Products Table
CREATE TABLE Products (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Price DECIMAL(18,2) NOT NULL
);
```

---

## 🚪 API Gateway (YARP)

### Konfigürasyon

```json
// appsettings.json
{
  "ReverseProxy": {
    "Routes": {
      "catalog-route": {
        "ClusterId": "catalog-cluster",
        "Match": {
          "Path": "/catalog-service/{**catch-all}"
        },
        "Transforms": [{ "PathPattern": "/{**catch-all}" }]
      },
      "basket-route": {
        "ClusterId": "basket-cluster",
        "Match": {
          "Path": "/basket-service/{**catch-all}"
        },
        "Transforms": [{ "PathPattern": "/{**catch-all}" }]
      }
    },
    "Clusters": {
      "catalog-cluster": {
        "Destinations": {
          "catalog-destination": {
            "Address": "http://catalog.api:8080/"
          }
        }
      },
      "basket-cluster": {
        "Destinations": {
          "basket-destination": {
            "Address": "http://basket.api:8080/"
          }
        }
      }
    }
  }
}
```

### Routing Strategy

```
Client Request → YARP Gateway → Microservice

https://localhost:6064/catalog-service/products
→ http://catalog.api:8080/products

https://localhost:6064/basket-service/basket/user1
→ http://basket.api:8080/basket/user1
```

---

## 📨 Messaging (RabbitMQ)

### Event-Driven Communication

```csharp
// Integration Events
public record BasketCheckoutEvent : IntegrationEvent
{
    public string UserName { get; init; } = default!;
    public decimal TotalPrice { get; init; }
    public string FirstName { get; init; } = default!;
    public string LastName { get; init; } = default!;
    public string EmailAddress { get; init; } = default!;
    public string AddressLine { get; init; } = default!;
    public string Country { get; init; } = default!;
    public string State { get; init; } = default!;
    public string ZipCode { get; init; } = default!;
    public string CardName { get; init; } = default!;
    public string CardNumber { get; init; } = default!;
    public string Expiration { get; init; } = default!;
    public string CVV { get; init; } = default!;
    public int PaymentMethod { get; init; }
}

// MassTransit Configuration
builder.Services.AddMassTransit(config =>
{
    config.SetKebabCaseEndpointNameFormatter();

    config.AddConsumer<BasketCheckoutEventHandler>();

    config.UsingRabbitMq((context, configurator) =>
    {
        configurator.Host(new Uri(builder.Configuration["MessageBroker:Host"]!), host =>
        {
            host.Username(builder.Configuration["MessageBroker:UserName"]!);
            host.Password(builder.Configuration["MessageBroker:Password"]!);
        });

        configurator.ConfigureEndpoints(context);
    });
});
```

### Message Flow

```
1. User clicks "Checkout" in Shopping.Web
2. Basket.API publishes BasketCheckoutEvent
3. RabbitMQ routes event to Ordering.API
4. Ordering.API handles event and creates order
5. Order confirmation sent back to user
```

---

## 🔐 Güvenlik

### HTTPS Configuration

```csharp
// Program.cs
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();  // HTTP Strict Transport Security
}

app.UseHttpsRedirection();
```

### CORS Configuration

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy",
        builder => builder
            .WithOrigins("https://localhost:6065")
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials());
});
```

### Input Validation

```csharp
// FluentValidation
public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Product name is required")
            .MaximumLength(200).WithMessage("Product name must not exceed 200 characters");

        RuleFor(x => x.Price)
            .GreaterThan(0).WithMessage("Price must be greater than 0");

        RuleFor(x => x.Category)
            .NotEmpty().WithMessage("Category is required");
    }
}
```

---

## 🚀 DevOps

### Docker Configuration

```dockerfile
# Catalog.API/Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Services/Catalog/Catalog.API/Catalog.API.csproj", "Services/Catalog/Catalog.API/"]
COPY ["BuildingBlocks/BuildingBlocks/BuildingBlocks.csproj", "BuildingBlocks/BuildingBlocks/"]
RUN dotnet restore "Services/Catalog/Catalog.API/Catalog.API.csproj"

COPY . .
WORKDIR "/src/Services/Catalog/Catalog.API"
RUN dotnet build "Catalog.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Catalog.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Catalog.API.dll"]
```

### Docker Compose

```yaml
# docker-compose.yml
version: "3.4"

services:
  catalogdb:
    image: postgres:15
    environment:
      POSTGRES_DB: CatalogDb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_catalog:/var/lib/postgresql/data

  catalog.api:
    image: catalogapi
    build:
      context: .
      dockerfile: Services/Catalog/Catalog.API/Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__Database=Host=catalogdb;Port=5432;Database=CatalogDb;Username=postgres;Password=postgres
    depends_on:
      - catalogdb
    ports:
      - "6000:8080"

volumes:
  postgres_catalog:
```

---

## 🔄 Kod Akışı

### 1. Ürün Listeleme İş Akışı

```
1. User → Shopping.Web/ProductList
2. ProductList.cshtml.cs → ICatalogService.GetProducts()
3. CatalogService (Refit) → API Gateway (YARP)
4. YARP → Catalog.API/products
5. GetProductsEndpoint → GetProductsHandler
6. GetProductsHandler → Marten Session
7. PostgreSQL query execution
8. Products returned as JSON
9. ProductModel binding in Razor Pages
10. HTML rendering with _ProductItemPartial
```

### 2. Sepete Ekleme İş Akışı

```
1. User clicks "Add to Cart" button
2. JavaScript AJAX request to Shopping.Web
3. Shopping.Web → IBasketService.StoreBasket()
4. BasketService (Refit) → API Gateway
5. YARP → Basket.API/basket
6. StoreBasketEndpoint → StoreBasketHandler
7. BasketRepository → Redis SET operation
8. Success response to client
9. UI notification display
```

### 3. Sipariş Oluşturma İş Akışı (CQRS + Events)

```
1. User proceeds to checkout
2. Shopping.Web → BasketCheckoutCommand
3. Basket.API validates and processes
4. BasketCheckoutEvent published to RabbitMQ
5. Ordering.API consumes event
6. BasketCheckoutEventHandler → CreateOrderCommand
7. CreateOrderCommandHandler processes
8. Order aggregate created (DDD)
9. OrderCreatedEvent raised
10. SQL Server transaction committed
11. Confirmation sent to user
```

### 4. İndirim Hesaplama İş Akışı (gRPC)

```
1. Basket calculation triggered
2. Basket.API → Discount.Grpc.GetDiscount()
3. gRPC call to Discount service
4. DiscountService queries SQLite
5. Coupon validation and amount calculation
6. gRPC response with discount amount
7. Basket total price adjusted
8. Updated basket displayed to user
```

---

## 📊 Performance Considerations

### Caching Strategy

```csharp
// Redis Caching in Basket Service
public class CachedBasketRepository : IBasketRepository
{
    private readonly IBasketRepository _repository;
    private readonly IDistributedCache _cache;

    public async Task<ShoppingCart> GetBasket(string userName, CancellationToken cancellationToken = default)
    {
        var cachedBasket = await _cache.GetStringAsync(userName, cancellationToken);
        if (!string.IsNullOrEmpty(cachedBasket))
            return JsonSerializer.Deserialize<ShoppingCart>(cachedBasket)!;

        var basket = await _repository.GetBasket(userName, cancellationToken);
        await _cache.SetStringAsync(userName, JsonSerializer.Serialize(basket), cancellationToken);

        return basket;
    }
}
```

### Database Optimization

```sql
-- PostgreSQL (Catalog)
CREATE INDEX CONCURRENTLY idx_products_category_gin
ON products USING GIN ((data->'Category'));

-- SQL Server (Ordering)
CREATE NONCLUSTERED INDEX IX_Orders_CustomerId_Status
ON Orders (CustomerId, Status)
INCLUDE (TotalPrice, CreatedAt);
```

### Async/Await Best Practices

```csharp
// Correct async usage
public async Task<GetProductsResult> Handle(GetProductsQuery query, CancellationToken cancellationToken)
{
    var queryable = session.Query<Product>();

    if (query.CategoryList?.Any() == true)
        queryable = queryable.Where(p => p.Category.Intersect(query.CategoryList).Any());

    var products = await queryable
        .Skip((query.PageNumber - 1) * query.PageSize)
        .Take(query.PageSize)
        .ToListAsync(cancellationToken);

    return new GetProductsResult(products);
}
```

---

## 🎯 İş Kuralları ve Domain Logic

### Ordering Domain (DDD Implementation)

```csharp
// Order Aggregate
public class Order : Aggregate<OrderId>
{
    private readonly List<OrderItem> _orderItems = new();
    public IReadOnlyList<OrderItem> OrderItems => _orderItems.AsReadOnly();

    public static Order Create(OrderId id, CustomerId customerId, OrderName orderName,
        Address shippingAddress, Address billingAddress, Payment payment)
    {
        var order = new Order
        {
            Id = id,
            CustomerId = customerId,
            OrderName = orderName,
            ShippingAddress = shippingAddress,
            BillingAddress = billingAddress,
            Payment = payment,
            Status = OrderStatus.Pending
        };

        order.AddDomainEvent(new OrderCreatedEvent(order));
        return order;
    }

    public void Add(ProductId productId, int quantity, decimal price)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(quantity);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(price);

        var orderItem = new OrderItem(Id, productId, quantity, price);
        _orderItems.Add(orderItem);
    }
}

// Value Objects
public record Address(string FirstName, string LastName, string EmailAddress,
    string AddressLine, string Country, string State, string ZipCode);

public record Payment(string CardName, string CardNumber, string Expiration,
    string Cvv, int PaymentMethod);
```

---

## 🧪 Testing Strategy

### Unit Tests (xUnit)

```csharp
public class CreateOrderCommandHandlerTests
{
    [Fact]
    public async Task Handle_ValidOrder_ShouldCreateOrder()
    {
        // Arrange
        var command = new CreateOrderCommand(/* parameters */);
        var handler = new CreateOrderCommandHandler(mockRepository.Object);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.Should().NotBeNull();
        result.IsSuccess.Should().BeTrue();
        mockRepository.Verify(x => x.Add(It.IsAny<Order>()), Times.Once);
    }
}
```

### Integration Tests

```csharp
public class CatalogApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task GetProducts_ShouldReturnProducts()
    {
        // Arrange
        var client = _factory.CreateClient();

        // Act
        var response = await client.GetAsync("/products");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var products = await response.Content.ReadFromJsonAsync<List<Product>>();
        products.Should().NotBeEmpty();
    }
}
```

---

Bu dokümantasyon, ToyShop projesinin tüm teknik detaylarını kapsamaktadır. Projede kullanılan her teknoloji, mimari pattern, kod akışı ve iş kuralı detaylıca açıklanmıştır. Gerçek bir enterprise mikroservis projesi olarak, modern yazılım geliştirme prensiplerini ve best practice'leri takip etmektedir.
