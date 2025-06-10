#!/usr/bin/env pwsh

Write-Host "🚀 EShop Microservices Startup Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Function to check if Docker is running
function Test-DockerRunning {
    try {
        docker info | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to wait for service to be healthy
function Wait-ForService {
    param(
        [string]$ServiceName,
        [string]$Url,
        [int]$MaxAttempts = 30
    )
    
    Write-Host "⏳ Waiting for $ServiceName to be ready..." -ForegroundColor Yellow
    
    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Url -Method Get -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $ServiceName is ready!" -ForegroundColor Green
                return $true
            }
        }
        catch {
            Write-Host "  Attempt $i/$MaxAttempts - $ServiceName not ready yet..." -ForegroundColor Gray
        }
        Start-Sleep -Seconds 5
    }
    
    Write-Host "❌ $ServiceName failed to start within timeout" -ForegroundColor Red
    return $false
}

# Check Docker
if (-not (Test-DockerRunning)) {
    Write-Host "❌ Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Docker is running" -ForegroundColor Green

# Clean up existing containers
Write-Host "🧹 Cleaning up existing containers..." -ForegroundColor Cyan
docker-compose -f docker-compose.yml -f docker-compose.override.yml down --remove-orphans 2>$null

# Remove any existing containers that might conflict
Write-Host "🗑️  Removing old containers..." -ForegroundColor Cyan
docker-compose -f docker-compose.yml -f docker-compose.override.yml rm -f 2>$null

# Build and start infrastructure services first
Write-Host "🏗️  Building and starting infrastructure services..." -ForegroundColor Cyan
Write-Host "  📊 Starting databases and message broker..." -ForegroundColor Gray

# Start databases and supporting services first
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d identitydb catalogdb basketdb orderdb distributedcache messagebroker

# Wait for databases
Write-Host "⏳ Waiting for databases to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Build application services
Write-Host "🏗️  Building application services..." -ForegroundColor Cyan
docker-compose -f docker-compose.yml -f docker-compose.override.yml build identity.api --no-cache
docker-compose -f docker-compose.yml -f docker-compose.override.yml build catalog.api --no-cache
docker-compose -f docker-compose.yml -f docker-compose.override.yml build basket.api --no-cache
docker-compose -f docker-compose.yml -f docker-compose.override.yml build discount.grpc --no-cache
docker-compose -f docker-compose.yml -f docker-compose.override.yml build ordering.api --no-cache
docker-compose -f docker-compose.yml -f docker-compose.override.yml build yarpapigateway --no-cache
docker-compose -f docker-compose.yml -f docker-compose.override.yml build shopping.web --no-cache

# Start all services
Write-Host "🚀 Starting all services..." -ForegroundColor Cyan
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

Write-Host ""
Write-Host "⏳ Services are starting up. This may take a few minutes..." -ForegroundColor Yellow
Write-Host ""

# Wait for key services
$services = @(
    @{ Name = "Identity Service"; Url = "http://localhost:5000/health" },
    @{ Name = "API Gateway"; Url = "http://localhost:6004" },
    @{ Name = "Shopping Web"; Url = "http://localhost:6005" }
)

foreach ($service in $services) {
    Wait-ForService -ServiceName $service.Name -Url $service.Url -MaxAttempts 20
}

# Show status
Write-Host ""
Write-Host "📊 Container Status:" -ForegroundColor Cyan
docker-compose -f docker-compose.yml -f docker-compose.override.yml ps

Write-Host ""
Write-Host "🎉 EShop Microservices Started Successfully!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "��� Access URLs:" -ForegroundColor White
Write-Host "  🛒 Shopping Web:     http://localhost:6005" -ForegroundColor Cyan
Write-Host "  🔑 Identity Service: http://localhost:5000" -ForegroundColor Cyan
Write-Host "  🚪 API Gateway:      http://localhost:6004" -ForegroundColor Cyan
Write-Host "  📦 Catalog API:      http://localhost:6000" -ForegroundColor Cyan
Write-Host "  🛍️  Basket API:       http://localhost:6001" -ForegroundColor Cyan
Write-Host "  📋 Ordering API:     http://localhost:6003" -ForegroundColor Cyan
Write-Host "  🎫 Discount gRPC:    http://localhost:6002" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 Admin URLs:" -ForegroundColor White
Write-Host "  🐰 RabbitMQ:         http://localhost:15672 (guest/guest)" -ForegroundColor Gray
Write-Host ""
Write-Host "👤 Test Users:" -ForegroundColor White
Write-Host "  👨‍💼 Admin:           admin@eshop.com / Password123!" -ForegroundColor Yellow
Write-Host "  👤 Customer:        customer@eshop.com / Password123!" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Troubleshooting:" -ForegroundColor White
Write-Host "  📊 Check status:    docker-compose ps" -ForegroundColor Gray
Write-Host "  📝 View logs:       docker-compose logs [service-name]" -ForegroundColor Gray
Write-Host "  🛑 Stop all:        docker-compose down" -ForegroundColor Gray
Write-Host "  🔄 Restart:         docker-compose restart [service-name]" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Next Steps:" -ForegroundColor White
Write-Host "  1. Open http://localhost:6005 in your browser" -ForegroundColor Cyan
Write-Host "  2. Register a new account or use test credentials" -ForegroundColor Cyan
Write-Host "  3. Browse products and test the shopping experience!" -ForegroundColor Cyan
Write-Host ""
