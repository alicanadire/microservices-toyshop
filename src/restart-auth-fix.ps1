#!/usr/bin/env pwsh

Write-Host "🔄 Restarting EShop services with authentication fix..." -ForegroundColor Green

# Stop existing containers
Write-Host "⏹️  Stopping existing containers..." -ForegroundColor Yellow
docker-compose down

# Remove any existing containers to ensure clean restart
Write-Host "🧹 Cleaning up containers..." -ForegroundColor Yellow
docker-compose rm -f

# Build and start services
Write-Host "🏗️  Building and starting services..." -ForegroundColor Yellow
docker-compose up -d --build

# Wait a moment for services to start
Write-Host "⏳ Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Show running containers
Write-Host "📋 Running containers:" -ForegroundColor Green
docker-compose ps

Write-Host ""
Write-Host "✅ Authentication fix applied! Services should be running on:" -ForegroundColor Green
Write-Host "   🔐 Identity Service: http://localhost:5000" -ForegroundColor Cyan
Write-Host "   🛒 Shopping Web:     http://localhost:6005" -ForegroundColor Cyan
Write-Host "   🌐 API Gateway:      http://localhost:6004" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Test the fix:" -ForegroundColor Yellow
Write-Host "   1. Go to http://localhost:6005" -ForegroundColor White
Write-Host "   2. Click 'Login' or 'Register'" -ForegroundColor White
Write-Host "   3. Should redirect to localhost:5000 (not identity.api:8080)" -ForegroundColor White
Write-Host ""
Write-Host "👤 Test credentials:" -ForegroundColor Yellow
Write-Host "   📧 Email: customer@eshop.com" -ForegroundColor White
Write-Host "   🔑 Password: Password123!" -ForegroundColor White
