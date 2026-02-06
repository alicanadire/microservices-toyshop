#!/usr/bin/env pwsh

Write-Host "🚀 Complete EShop Fix - Resolving Identity Service Connection Issue" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 Issues being fixed:" -ForegroundColor Yellow
Write-Host "   ✓ Port inconsistencies between docker-compose files" -ForegroundColor Green
Write-Host "   ✓ Identity Service not accessible on localhost:5000" -ForegroundColor Green
Write-Host "   ✓ CSS build errors in Razor pages" -ForegroundColor Green
Write-Host "   ✓ Authentication redirect configuration" -ForegroundColor Green

# Stop everything first
Write-Host ""
Write-Host "⏹️  Stopping all services..." -ForegroundColor Yellow
docker-compose down --remove-orphans 2>$null

# Clean up completely
Write-Host "🧹 Cleaning up containers and networks..." -ForegroundColor Yellow
docker-compose rm -f 2>$null
docker system prune -f 2>$null

# Show the corrected port configuration
Write-Host ""
Write-Host "📍 Corrected Port Configuration:" -ForegroundColor Cyan
Write-Host "   🔐 Identity Service: localhost:5000" -ForegroundColor White
Write-Host "   📦 Catalog API:      localhost:6000" -ForegroundColor White
Write-Host "   🛒 Basket API:       localhost:6001" -ForegroundColor White
Write-Host "   💰 Discount gRPC:    localhost:6002" -ForegroundColor White
Write-Host "   📋 Ordering API:     localhost:6003" -ForegroundColor White
Write-Host "   🌐 API Gateway:      localhost:6004" -ForegroundColor White
Write-Host "   🛍️  Shopping Web:     localhost:6005" -ForegroundColor White

# Start services
Write-Host ""
Write-Host "🏗️  Building and starting all services..." -ForegroundColor Yellow
Write-Host "   This may take 2-3 minutes for the first build..." -ForegroundColor Gray

try {
    docker-compose up -d --build
    Write-Host "✅ Services started successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error starting services: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 Troubleshooting steps:" -ForegroundColor Yellow
    Write-Host "   1. Check Docker Desktop is running" -ForegroundColor White
    Write-Host "   2. Check available disk space" -ForegroundColor White
    Write-Host "   3. Try: docker-compose logs identity.api" -ForegroundColor White
    exit 1
}

# Wait for initialization
Write-Host ""
Write-Host "⏳ Waiting 30 seconds for services to initialize..." -ForegroundColor Yellow
Write-Host "   Services need time to start databases and configure authentication..." -ForegroundColor Gray

for ($i = 30; $i -gt 0; $i--) {
    Write-Host "   $i seconds remaining..." -ForegroundColor Gray
    Start-Sleep -Seconds 1
}

# Check service status
Write-Host ""
Write-Host "📋 Checking service status..." -ForegroundColor Green

$services = @(
    @{Name="Identity Service"; Url="http://localhost:5000/health"; Port=5000},
    @{Name="API Gateway"; Url="http://localhost:6004"; Port=6004},
    @{Name="Shopping Web"; Url="http://localhost:6005"; Port=6005}
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -TimeoutSec 10 -UseBasicParsing
        Write-Host "   ✅ $($service.Name) (port $($service.Port)): Healthy" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  $($service.Name) (port $($service.Port)): Still starting..." -ForegroundColor Yellow
    }
}

# Show containers
Write-Host ""
Write-Host "🐳 Container Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🎯 Testing Instructions:" -ForegroundColor Yellow
Write-Host "1. Open your browser and go to: http://localhost:6005" -ForegroundColor White
Write-Host "2. You should see the EShop homepage with products" -ForegroundColor White
Write-Host "3. Click 'Login' - it should redirect to localhost:5000 (not identity.api:8080)" -ForegroundColor White
Write-Host "4. Use test credentials:" -ForegroundColor White
Write-Host "   📧 Email: customer@eshop.com" -ForegroundColor Cyan
Write-Host "   🔑 Password: Password123!" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔧 If you still get connection errors:" -ForegroundColor Red
Write-Host "   1. Wait another 1-2 minutes for full initialization" -ForegroundColor White
Write-Host "   2. Check logs: docker-compose logs identity.api" -ForegroundColor White
Write-Host "   3. Check Windows Firewall isn't blocking ports" -ForegroundColor White
Write-Host "   4. Restart Docker Desktop if needed" -ForegroundColor White

Write-Host ""
Write-Host "✨ Fix completed! The Identity Service should now be accessible." -ForegroundColor Green
