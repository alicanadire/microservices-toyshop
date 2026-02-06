# 🏪 .NET 8 Microservices E-Commerce Application - Setup Guide

## 🚀 Quick Start (Current State)

The development server is now running successfully and serving static files at:
**http://localhost:6065**

### Current Status ✅

- ✅ Package.json created and configured
- ✅ HTTP server running on port 6065
- ✅ Static files being served from ASP.NET Core wwwroot
- ✅ Development environment is functional

## 🎯 What You're Seeing Now

You're currently viewing a **static file server** that serves the frontend assets of the ASP.NET Core web application. This is a temporary development solution while the full Docker-based microservices infrastructure is not available.

## 🏗️ Full Application Architecture

This is a comprehensive .NET 8 microservices e-commerce application with:

### Microservices

- **Catalog API** (Port 6000) - Product management with PostgreSQL
- **Basket API** (Port 6001) - Shopping cart with Redis cache
- **Discount gRPC** (Port 6002) - Discount service with SQLite
- **Ordering API** (Port 6003) - Order management with SQL Server
- **YARP Gateway** (Port 6004) - API Gateway with rate limiting
- **Shopping Web** (Port 6005) - ASP.NET Core Razor Pages frontend

### Infrastructure

- **PostgreSQL** - Catalog and Basket databases
- **SQL Server** - Ordering database
- **SQLite** - Discount database
- **Redis** - Distributed caching
- **RabbitMQ** - Message broker for event-driven communication

## 🔧 How to Run the Complete Application

### Prerequisites

1. **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)
2. **.NET 8 SDK** - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
3. **Visual Studio 2022** or **VS Code** (recommended)

### Setup Steps

#### Option 1: Docker Compose (Recommended)

```bash
# Navigate to the source directory
cd src

# Build and start all services
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

# Wait for services to start (2-5 minutes)
# Access the application at: https://localhost:6065
```

#### Option 2: Windows PowerShell Setup Script

```powershell
# Run as Administrator
.\setup.ps1
```

#### Option 3: Manual Service Startup

```bash
# Start infrastructure services
docker-compose up catalogdb basketdb orderdb distributedcache messagebroker -d

# Build and run each microservice individually
cd Services/Catalog/Catalog.API
dotnet run

cd ../../../Services/Basket/Basket.API
dotnet run

# ... repeat for other services
```

### Service Endpoints

Once fully running:

- **Shopping Web UI**: https://localhost:6065
- **API Gateway**: https://localhost:6064
- **Catalog API**: https://localhost:6060
- **Basket API**: https://localhost:6061
- **Discount gRPC**: https://localhost:6062
- **Ordering API**: https://localhost:6063
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)

## 📚 Architecture Patterns Used

- **Domain Driven Design (DDD)**
- **Command Query Responsibility Segregation (CQRS)**
- **Event-Driven Architecture**
- **Clean Architecture**
- **Vertical Slice Architecture**
- **Microservices Pattern**
- **API Gateway Pattern**
- **Database per Service**
- **Event Sourcing**

## 🛠️ Current Development Commands

```bash
# Install dependencies
npm install

# Start development server (static files)
npm run dev

# Get project information
npm run info

# Docker commands (when Docker is available)
npm run docker:up
npm run docker:build
npm run docker:down
```

## 🔍 Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 5432, 5433, 1433, 6379, 5672, 6000-6005 are available
2. **Docker Memory**: Allocate at least 4GB RAM to Docker Desktop
3. **SSL Certificates**: Run `dotnet dev-certs https --trust` if SSL issues occur
4. **Firewall**: Allow Docker and .NET applications through Windows Firewall

### Health Checks

```bash
# Check service health (when running)
curl http://localhost:6000/health  # Catalog API
curl http://localhost:6001/health  # Basket API
curl http://localhost:6003/health  # Ordering API
curl http://localhost:6004/health  # Gateway
```

## 📖 Learning Resources

- **GitHub Repository**: https://github.com/aspnetrun/run-aspnetcore-microservices
- **Udemy Course**: [Microservices Architecture and Implementation on .NET](https://www.udemy.com/course/microservices-architecture-and-implementation-on-dotnet/)
- **Medium Article**: [.NET 8 Microservices: DDD, CQRS, Vertical/Clean Architecture](https://medium.com/@mehmetozkaya/net-8-microservices-ddd-cqrs-vertical-clean-architecture-2dd7ebaaf4bd)

## 👨‍💻 Author

**Mehmet Ozkaya**  
Senior Software Engineer & Instructor  
Specializing in .NET, Microservices, and Cloud Architecture

## 📝 License

This project is licensed under the MIT License.

---

## 🚨 Current Limitation Notice

**Important**: The current development server only serves static files. To experience the full e-commerce functionality including:

- Product catalog browsing
- Shopping cart operations
- Order management
- User authentication
- Real-time updates

You need to run the complete Docker Compose setup as described above.

The static server is useful for:

- Frontend development and styling
- Static asset testing
- Basic UI/UX validation
- Development environment verification
