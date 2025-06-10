#!/usr/bin/env pwsh

Write-Host "🍃 Identity Server with MongoDB Startup" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host "🎯 NoSQL database ile modern kimlik yönetimi!" -ForegroundColor Yellow
Write-Host ""

# Complete cleanup
Write-Host "🧹 Tam temizlik yapılıyor..." -ForegroundColor Cyan
docker-compose down --remove-orphans 2>$null
docker system prune -f 2>$null

# Start MongoDB first
Write-Host "🍃 MongoDB başlatılıyor..." -ForegroundColor Green
docker-compose up -d mongodb

Write-Host "⏳ MongoDB'nin hazır olmasını bekliyor..." -ForegroundColor Yellow
$mongoReady = $false
$attempts = 0

while (-not $mongoReady -and $attempts -lt 20) {
    try {
        $result = docker exec mongodb mongosh --eval "db.adminCommand('ping')" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $mongoReady = $true
            Write-Host "✅ MongoDB hazır!" -ForegroundColor Green
        }
    } catch {
        $attempts++
        Write-Host "  Deneme $attempts/20 - MongoDB henüz hazır değil..." -ForegroundColor Gray
        Start-Sleep -Seconds 3
    }
}

if (-not $mongoReady) {
    Write-Host "❌ MongoDB başlatılamadı!" -ForegroundColor Red
    exit 1
}

# Build Identity Service with MongoDB
Write-Host "🏗️  Identity Service'i MongoDB ile build ediliyor..." -ForegroundColor Cyan
docker-compose build identity.api --no-cache

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build hatası!" -ForegroundColor Red
    exit 1
}

# Start Identity Service
Write-Host "🚀 Identity Service başlatılıyor..." -ForegroundColor Green
docker-compose up -d identity.api

# Monitor startup
Write-Host "📊 Service durumunu izliyorum..." -ForegroundColor Yellow
for ($i = 1; $i -le 30; $i++) {
    $containerStatus = docker-compose ps -q identity.api | ForEach-Object { docker inspect $_ --format '{{.State.Status}}' }
    
    if ($containerStatus -eq "running") {
        Write-Host "  [$i/30] ✅ Container çalışıyor" -ForegroundColor Green
        
        # Test health endpoint
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 3
            if ($response.StatusCode -eq 200) {
                Write-Host "🎉 BAŞARILI! Identity Server MongoDB ile çalışıyor!" -ForegroundColor Green
                break
            }
        } catch {
            # Continue monitoring
        }
    } else {
        Write-Host "  [$i/30] ⚠️ Container durumu: $containerStatus" -ForegroundColor Yellow
        
        if ($containerStatus -eq "exited") {
            Write-Host "❌ Container çıktı! Log'ları:" -ForegroundColor Red
            docker-compose logs --tail=20 identity.api
            break
        }
    }
    
    Start-Sleep -Seconds 2
}

# Final status
Write-Host ""
Write-Host "📊 Final Durum:" -ForegroundColor Cyan
docker-compose ps

# Test endpoints
Write-Host ""
Write-Host "🧪 Endpoint testleri:" -ForegroundColor Cyan

$endpoints = @(
    @{ Name = "Health Check"; Url = "http://localhost:5000/health" },
    @{ Name = "Service Info"; Url = "http://localhost:5000" },
    @{ Name = "Debug Config"; Url = "http://localhost:5000/debug/config" },
    @{ Name = "Users Info"; Url = "http://localhost:5000/debug/users" }
)

foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.Url -UseBasicParsing -TimeoutSec 5
        Write-Host "  ✅ $($endpoint.Name) - Çalışıyor" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $($endpoint.Name) - Cevap vermiyor" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 MongoDB Identity Server Çalışıyor!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Test URL'leri:" -ForegroundColor White
Write-Host "  🏥 Health:     http://localhost:5000/health" -ForegroundColor Cyan
Write-Host "  📋 Service:    http://localhost:5000" -ForegroundColor Cyan  
Write-Host "  🔍 Debug:      http://localhost:5000/debug/config" -ForegroundColor Cyan
Write-Host "  👥 Users:      http://localhost:5000/debug/users" -ForegroundColor Cyan
Write-Host ""
Write-Host "🍃 MongoDB:" -ForegroundColor White
Write-Host "  📊 Connection: mongodb://admin:password123@localhost:27017/IdentityDb" -ForegroundColor Gray
Write-Host "  🗄️ Database:   IdentityDb" -ForegroundColor Gray
Write-Host "  📁 Collections: users, roles" -ForegroundColor Gray
Write-Host ""
Write-Host "👤 Test Kullanıcıları:" -ForegroundColor White
Write-Host "  📧 admin@eshop.com / Password123!" -ForegroundColor Yellow
Write-Host "  📧 customer@eshop.com / Password123!" -ForegroundColor Yellow
Write-Host ""
Write-Host "🛒 Şimdi Shopping Web'i başlatabilirsiniz:" -ForegroundColor White
Write-Host "  docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 MongoDB Yönetimi:" -ForegroundColor White
Write-Host "  docker exec -it mongodb mongosh" -ForegroundColor Gray
Write-Host "  use IdentityDb" -ForegroundColor Gray
Write-Host "  db.users.find()" -ForegroundColor Gray
Write-Host ""
