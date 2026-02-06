#!/usr/bin/env pwsh

Write-Host "🔍 Diagnosing EShop Services..." -ForegroundColor Green

# Check if Docker is running
Write-Host "📋 Checking Docker status..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker is available: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not available or not running" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again" -ForegroundColor Yellow
    exit 1
}

# Check current containers
Write-Host "📦 Checking current containers..." -ForegroundColor Yellow
$containers = docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host $containers

# Check if any containers are running
$runningContainers = docker ps --format "{{.Names}}"
if ($runningContainers) {
    Write-Host "🟢 Running containers found:" -ForegroundColor Green
    foreach ($container in $runningContainers) {
        Write-Host "   - $container" -ForegroundColor White
    }
} else {
    Write-Host "🔴 No containers are currently running" -ForegroundColor Red
}

# Check port availability
Write-Host "🔌 Checking port availability..." -ForegroundColor Yellow
$ports = @(5000, 6004, 6005, 5432, 5433, 5434)
foreach ($port in $ports) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "   Port $port: ✅ In use" -ForegroundColor Green
        } else {
            Write-Host "   Port $port: 🔴 Available" -ForegroundColor Red
        }
    } catch {
        Write-Host "   Port $port: 🔴 Available" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🛠️  Attempting to fix the issue..." -ForegroundColor Green

# Stop any existing containers
Write-Host "⏹️  Stopping existing containers..." -ForegroundColor Yellow
docker-compose down 2>$null

# Clean up containers and networks
Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
docker-compose rm -f 2>$null
docker system prune -f 2>$null

# Build and start services
Write-Host "🏗️  Building and starting all services..." -ForegroundColor Yellow
try {
    docker-compose up -d --build
    Write-Host "✅ Services started successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to start services" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

# Wait for services to initialize
Write-Host "⏳ Waiting 20 seconds for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Check services again
Write-Host "🔍 Checking services after startup..." -ForegroundColor Green
$newContainers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host $newContainers

# Test specific endpoints
Write-Host "🌐 Testing service endpoints..." -ForegroundColor Green

# Test Identity Service
try {
    $identityResponse = Invoke-WebRequest -Uri "http://localhost:5000/health" -TimeoutSec 5 -UseBasicParsing
    if ($identityResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Identity Service (port 5000): Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Identity Service (port 5000): Not responding" -ForegroundColor Red
}

# Test API Gateway
try {
    $gatewayResponse = Invoke-WebRequest -Uri "http://localhost:6004" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ API Gateway (port 6004): Responding" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API Gateway (port 6004): Not responding" -ForegroundColor Red
}

# Test Shopping Web
try {
    $webResponse = Invoke-WebRequest -Uri "http://localhost:6005" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Shopping Web (port 6005): Responding" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Shopping Web (port 6005): Not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Service Status Summary:" -ForegroundColor Cyan
Write-Host "   🔐 Identity Service: http://localhost:5000 (IdentityServer4)" -ForegroundColor White
Write-Host "   🌐 API Gateway:      http://localhost:6004 (YARP Proxy)" -ForegroundColor White
Write-Host "   🛒 Shopping Web:     http://localhost:6005 (Main Application)" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Wait 1-2 minutes for all services to fully initialize" -ForegroundColor White
Write-Host "   2. Go to http://localhost:6005 to test the application" -ForegroundColor White
Write-Host "   3. If still having issues, check Docker logs: docker-compose logs identity.api" -ForegroundColor White

Write-Host ""
Write-Host "🔧 If problems persist, try:" -ForegroundColor Yellow
Write-Host "   - Restart Docker Desktop" -ForegroundColor White
Write-Host "   - Check Windows Firewall settings" -ForegroundColor White
Write-Host "   - Run: docker-compose logs [service-name] for detailed logs" -ForegroundColor White
