#!/usr/bin/env pwsh

Write-Host "🔍 Identity Server Debug Mode" -ForegroundColor Yellow
Write-Host "============================" -ForegroundColor Yellow

# Stop existing container
Write-Host "🛑 Mevcut container'ı durduruyor..." -ForegroundColor Cyan
docker-compose stop identity.api 2>$null
docker-compose rm -f identity.api 2>$null

# Check if database is running
Write-Host "📊 Database durumunu kontrol ediyor..." -ForegroundColor Cyan
$dbStatus = docker-compose ps identitydb
Write-Host $dbStatus

# Start database if not running
Write-Host "🗄️  Database'i başlatıyor..." -ForegroundColor Cyan
docker-compose up -d identitydb

Write-Host "⏳ Database'in hazır olmasını bekliyor (30 saniye)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Test database connection
Write-Host "🧪 Database bağlantısını test ediyor..." -ForegroundColor Cyan
try {
    docker exec identitydb pg_isready -U postgres
    Write-Host "✅ Database hazır!" -ForegroundColor Green
} catch {
    Write-Host "❌ Database bağlantı problemi!" -ForegroundColor Red
}

# Rebuild identity service
Write-Host "🏗️  Identity Service'i rebuild ediyor..." -ForegroundColor Cyan
docker-compose build identity.api --no-cache

# Start with detailed logging
Write-Host "🚀 Identity Service'i detaylı log ile başlatıyor..." -ForegroundColor Green
docker-compose up identity.api

Write-Host ""
Write-Host "🔍 Eğer hata varsa yukarıda görünecek." -ForegroundColor Yellow
Write-Host "📝 Log'ları görmek için: docker-compose logs identity.api" -ForegroundColor Gray
