# EShop Microservices - Build Instructions

## 🚨 Docker Build Issue Fix

If you're experiencing Docker build errors, follow these steps:

### Step 1: Clean Environment

```bash
cd src

# Stop all containers
docker-compose down --remove-orphans

# Clean up images
docker rmi identityapi 2>/dev/null || true
docker builder prune -f
```

### Step 2: Build Identity Service First

```bash
# Build only Identity service to test
docker-compose build identity.api
```

### Step 3: Build All Services

```bash
# If Identity build succeeds, build all
docker-compose build --no-cache
```

### Step 4: Start Services

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

## 🐛 Common Issues & Solutions

### Issue 1: "File not found" in Dockerfile

**Solution**: Make sure you're running commands from the `src` directory, not the root project directory.

### Issue 2: SSL Certificate Issues

**Solution**:

```bash
# Generate development certificates
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

### Issue 3: Port Conflicts

**Solution**: Check if ports are in use:

```bash
# Windows
netstat -ano | findstr :5001
netstat -ano | findstr :6005

# Linux/Mac
lsof -i :5001
lsof -i :6005
```

## 🎯 Manual Service Startup (Alternative)

If Docker continues to have issues, you can run services manually:

### 1. Start Databases First

```bash
# PostgreSQL for Identity
docker run -d --name identitydb -p 5434:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=IdentityDb postgres

# PostgreSQL for Catalog
docker run -d --name catalogdb -p 5432:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=CatalogDb postgres

# Redis
docker run -d --name redis -p 6379:6379 redis
```

### 2. Run Identity Service

```bash
cd Services/Identity/Identity.API
dotnet run --urls="https://localhost:5001;http://localhost:5000"
```

### 3. Run Other Services

```bash
# API Gateway
cd ApiGateways/YarpApiGateway
dotnet run --urls="http://localhost:6004"

# Shopping Web
cd WebApps/Shopping.Web
dotnet run --urls="http://localhost:6005"

# Catalog API
cd Services/Catalog/Catalog.API
dotnet run --urls="http://localhost:6000"
```

## ✅ Verification

After startup, verify services are running:

1. **Identity Service**: https://localhost:5001
2. **Shopping Web**: http://localhost:6005
3. **API Gateway**: http://localhost:6004

## 🔑 Test Credentials

- **Admin**: admin@eshop.com / Password123!
- **Customer**: customer@eshop.com / Password123!

## 📞 Need Help?

If issues persist:

1. Check Docker Desktop is running
2. Ensure .NET 8 SDK is installed
3. Verify all project files are in place
4. Check firewall/antivirus isn't blocking ports
5. Try running with administrator/sudo privileges

## 🎉 Success Indicators

When everything is working:

- ✅ Identity Service shows login page at https://localhost:5001
- ✅ Shopping Web loads at http://localhost:6005
- ✅ Login redirects to Identity Service and back
- ✅ Protected pages (Cart, Orders) require authentication
