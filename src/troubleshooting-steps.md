# 🚨 Identity Service Connection Issue - Troubleshooting Guide

## Problem

The Shopping Web application cannot connect to the Identity Service at `http://localhost:5000`.

Error: `Connection refused (localhost:5000)`

## Cause

The Identity Service container is not running or not accessible on port 5000.

## Solution Steps

### Step 1: Check Current Container Status

```bash
cd src
docker-compose ps
```

### Step 2: Stop and Clean Everything

```bash
docker-compose down
docker-compose rm -f
docker system prune -f
```

### Step 3: Rebuild and Start Services

```bash
docker-compose up -d --build
```

### Step 4: Wait and Check Logs

```bash
# Wait 30 seconds then check logs
docker-compose logs identity.api
docker-compose logs shopping.web
```

### Step 5: Verify Services

```bash
# Check if containers are running
docker-compose ps

# Test endpoints
curl http://localhost:5000/health      # Identity Service
curl http://localhost:6004             # API Gateway
curl http://localhost:6005             # Shopping Web
```

## Expected Service Ports

- 🔐 **Identity Service**: `http://localhost:5000`
- 🌐 **API Gateway**: `http://localhost:6004`
- 🛒 **Shopping Web**: `http://localhost:6005`
- 📦 **Catalog API**: `http://localhost:6000`
- 🛒 **Basket API**: `http://localhost:6001`
- 📋 **Ordering API**: `http://localhost:6003`

## Common Issues & Fixes

### Issue 1: Port Conflicts

**Problem**: Another application is using port 5000
**Solution**:

```bash
# Check what's using port 5000
netstat -ano | findstr :5000
# Kill the process or change the port in docker-compose.override.yml
```

### Issue 2: Docker Not Running

**Problem**: Docker Desktop is not started
**Solution**: Start Docker Desktop and wait for it to be ready

### Issue 3: Build Errors

**Problem**: Container fails to build
**Solution**:

```bash
# Check specific service logs
docker-compose logs identity.api
# Rebuild specific service
docker-compose up -d --build identity.api
```

### Issue 4: Memory/Resource Issues

**Problem**: Not enough resources to run all containers
**Solution**:

1. Close other applications
2. Increase Docker Desktop memory allocation
3. Start services one by one

## Manual Service Testing

### Test Identity Service Directly

```bash
# Should return "Identity Service API - Running"
curl http://localhost:5000

# Should return OpenID Connect configuration
curl http://localhost:5000/.well-known/openid-configuration
```

### Test Shopping Web

```bash
# Should show the homepage
curl http://localhost:6005
```

## Emergency Manual Startup

If Docker Compose fails, try starting services manually:

```bash
# Start databases first
docker run -d --name identitydb -p 5434:5432 -e POSTGRES_PASSWORD=postgres postgres:15

# Build and run Identity Service
cd src/Services/Identity/Identity.API
dotnet run --urls="http://localhost:5000"

# In another terminal, run Shopping Web
cd src/WebApps/Shopping.Web
dotnet run --urls="http://localhost:6005"
```

## Success Indicators

✅ `docker-compose ps` shows all services as "Up"  
✅ `curl http://localhost:5000/health` returns 200 OK  
✅ `curl http://localhost:6005` returns HTML content  
✅ No "Connection refused" errors in logs

## Need Help?

If these steps don't work, run the diagnosis script:

```powershell
.\diagnose-and-fix.ps1
```
