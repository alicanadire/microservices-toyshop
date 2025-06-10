# 🧸 ToyShop - Modern Oyuncak Mağazası

Bu proje .NET 8 mikroservis mimarisi ile geliştirilmiş modern bir oyuncak e-ticaret platformudur. Geliştirme ortamı Node.js ile frontend önizlemesi sağlarken, gerçek uygulama .NET ve Docker ile çalışacak şekilde tasarlanmı��tır.

## 🚀 Hızlı Başlangıç (Geliştirme Önizlemesi)

Geliştirme sunucusu çalışıyor ve oyuncak mağazasının modern arayüzünü sunuyor:

- **Ana Sayfa**: http://localhost:3000/ - Oyuncak kategorileri ve öne çıkan ürünler
- **Oyuncaklar**: http://localhost:3000/products - Tüm oyuncak kataloğu
- **Sepet**: http://localhost:3000/cart - Alışveriş sepeti
- **Siparişler**: http://localhost:3000/orders - Sipariş geçmişi
- **İletişim**: http://localhost:3000/contact - Müşteri desteği

## 📁 Project Structure

```
eshop-microservices/
├── src/
│   ├── ApiGateways/YarpApiGateway/          # API Gateway using YARP
│   ├── BuildingBlocks/                      # Shared libraries
│   ├── Services/
│   │   ├── Basket/Basket.API/              # Shopping Cart Service
│   │   ├── Catalog/Catalog.API/            # Product Catalog Service
│   │   ├── Discount/Discount.Grpc/         # Discount Service (gRPC)
│   │   └── Ordering/                       # Order Management Service
│   └── WebApps/Shopping.Web/               # Frontend Web Application (ASP.NET Core Razor Pages)
├── package.json                            # Node.js development setup
├── server.js                              # Development server
└── setup.ps1                              # PowerShell setup script for full environment
```

## 🛠️ Current Setup (Development Mode)

### What's Working:

✅ Frontend preview with mock data
✅ Responsive design with Bootstrap 4
✅ Navigation between pages
✅ Product listing and details
✅ Contact form (UI only)
✅ API endpoints for testing

### What's Not Available (Requires Full Setup):

❌ Backend microservices
❌ Database functionality
❌ Authentication/Authorization
❌ Real cart and checkout
❌ Order processing
❌ Payment integration

## 🔧 Development Commands

```bash
# Start development server
npm run dev

# Install dependencies
npm install

# View available scripts
npm run
```

## 🏗️ Full Production Setup

To run the complete microservices application, you need:

### Prerequisites:

- **.NET 8 SDK**
- **Docker Desktop**
- **Docker Compose**
- **PowerShell** (for Windows setup)

### Databases:

- **PostgreSQL** (Catalog & Basket services)
- **SQL Server** (Ordering service)
- **Redis** (Caching)
- **RabbitMQ** (Message broker)

### Setup Steps:

1. **Install Prerequisites** listed above
2. **Run Setup Script**:
   ```powershell
   .\setup.ps1
   ```
3. **Or Manual Docker Setup**:
   ```bash
   cd src
   docker-compose up -d
   ```

### Production URLs (after full setup):

- Shopping Web UI: https://localhost:6065
- API Gateway: https://localhost:6064
- Catalog API: https://localhost:6060
- Basket API: https://localhost:6061
- Discount gRPC: https://localhost:6062
- Ordering API: https://localhost:6063
- RabbitMQ Management: http://localhost:15672

## 🏛️ Architecture Overview

This is a **microservices architecture** implementing:

### Services:

1. **Catalog.API** - Product catalog management
2. **Basket.API** - Shopping cart functionality
3. **Discount.Grpc** - Discount and coupon system
4. **Ordering.API** - Order processing and management
5. **YarpApiGateway** - API Gateway for service routing

### Patterns Implemented:

- **CQRS** (Command Query Responsibility Segregation)
- **Clean Architecture**
- **Domain-Driven Design**
- **Event-Driven Architecture**
- **API Gateway Pattern**
- **Database per Service**

### Technologies:

- **.NET 8** - Backend services
- **ASP.NET Core** - Web framework
- **Entity Framework Core** - ORM
- **MediatR** - CQRS implementation
- **FluentValidation** - Input validation
- **MassTransit** - Message bus
- **YARP** - Reverse proxy
- **Docker** - Containerization
- **PostgreSQL & SQL Server** - Databases
- **Redis** - Caching
- **RabbitMQ** - Message broker

## 🧪 API Testing

### Available Development API Endpoints:

```
GET /api/products           # Get all products
GET /api/products/:id       # Get product by ID
```

### Example API Calls:

```bash
# Get all products
curl http://localhost:3000/api/products

# Get specific product
curl http://localhost:3000/api/products/1
```

## 🔍 Troubleshooting

### Common Issues:

1. **Port 3000 already in use**:

   ```bash
   # Change port in server.js or:
   PORT=3001 npm run dev
   ```

2. **Missing dependencies**:

   ```bash
   npm install
   ```

3. **For full .NET setup issues**:
   - Ensure Docker Desktop is running
   - Check PowerShell execution policy
   - Verify .NET 8 SDK installation

## 🚧 Development Notes

This development setup provides a **frontend preview only**. It's designed to:

- Allow frontend development and testing
- Demonstrate the UI/UX design
- Provide mock API endpoints
- Serve as a starting point for development

For **full functionality**, the complete .NET microservices environment must be set up using Docker Compose.

## 📞 Support

For issues related to:

- **Development preview**: Check browser console and server logs
- **Full setup**: Refer to `setup.ps1` script and Docker logs
- **Architecture questions**: Review the source code in `/src` directory

---

**Note**: This is a development environment setup. The actual application is a sophisticated .NET 8 microservices architecture designed for production use.
