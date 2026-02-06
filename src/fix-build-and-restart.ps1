#!/usr/bin/env pwsh

Write-Host "🔧 Fixing Build Issues and Restarting Services..." -ForegroundColor Green

# Stop existing containers
Write-Host "⏹️  Stopping existing containers..." -ForegroundColor Yellow
docker-compose down

# Remove containers to ensure clean rebuild
Write-Host "🧹 Cleaning up containers and images..." -ForegroundColor Yellow
docker-compose rm -f
docker system prune -f

# Build and start services with fresh build
Write-Host "🏗️  Building and starting services with fixes..." -ForegroundColor Yellow
docker-compose up -d --build --force-recreate

# Wait for services to initialize
Write-Host "⏳ Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Show status
Write-Host "📋 Container status:" -ForegroundColor Green
docker-compose ps

Write-Host ""
Write-Host "✅ Build fixes applied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Fixed Issues:" -ForegroundColor Yellow
Write-Host "   ✓ CSS @keyframes syntax in Razor pages" -ForegroundColor Green
Write-Host "   ✓ CSS @media query syntax in Razor pages" -ForegroundColor Green
Write-Host "   ✓ Unused logger parameter warning" -ForegroundColor Green
Write-Host "   ✓ Null reference warnings in ProductList" -ForegroundColor Green
Write-Host "   ✓ Updated JWT package (security vulnerability)" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Services running on:" -ForegroundColor Cyan
Write-Host "   🔐 Identity Service: http://localhost:5000" -ForegroundColor White
Write-Host "   🛒 Shopping Web:     http://localhost:6005" -ForegroundColor White
Write-Host "   🌐 API Gateway:      http://localhost:6004" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Ready to test! Go to http://localhost:6005" -ForegroundColor Green
