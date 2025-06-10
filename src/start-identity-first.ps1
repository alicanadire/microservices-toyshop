#!/usr/bin/env pwsh

Write-Host "🔑 EShop Identity Server First Startup" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host "🎯 Identity Server MUTLAKA çalışacak!" -ForegroundColor Yellow
Write-Host ""

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker bulunamadı. Docker Desktop'ı kurun." -ForegroundColor Red
    exit 1
}

try {
    docker info | Out-Null
    Write-Host "✅ Docker çalışıyor" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker çalışmıyor. Docker Desktop'ı başlatın." -ForegroundColor Red
    exit 1
}

# Use fixed compose file
$composeFile = "docker-compose.fixed.yml"
if (-not (Test-Path $composeFile)) {
    Write-Host "❌ $composeFile bulunamadı. Doğru dizinde olduğunuzdan emin olun." -ForegroundColor Red
    exit 1
}

Write-Host "🧹 Mevcut container'ları temizliyorum..." -ForegroundColor Cyan
docker-compose -f $composeFile down --remove-orphans 2>$null
docker system prune -f 2>$null

Write-Host "🏗️  Infrastructure servislerini başlatıyorum..." -ForegroundColor Cyan
docker-compose -f $composeFile up -d identitydb catalogdb basketdb orderdb distributedcache messagebroker

Write-Host "⏳ Veritabanlarının hazır olmasını bekliyorum..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "🔑 Identity Server'ı build ediyorum (ÖNCELIK)..." -ForegroundColor Green
docker-compose -f $composeFile build identity.api --no-cache

Write-Host "🚀 Identity Server'ı başlatıyorum..." -ForegroundColor Green
docker-compose -f $composeFile up -d identity.api

Write-Host "⏳ Identity Server'ın hazır olmasını bekliyorum..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 1

do {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Identity Server hazır!" -ForegroundColor Green
            break
        }
    } catch {
        Write-Host "  Deneme $attempt/$maxAttempts - Identity Server henüz hazır değil..." -ForegroundColor Gray
        $attempt++
        Start-Sleep -Seconds 3
    }
} while ($attempt -le $maxAttempts)

if ($attempt -gt $maxAttempts) {
    Write-Host "❌ Identity Server başlatılamadı! Logları kontrol edin:" -ForegroundColor Red
    Write-Host "docker-compose -f $composeFile logs identity.api" -ForegroundColor Gray
    exit 1
}

Write-Host "🏗️  Diğer servisleri build ediyorum..." -ForegroundColor Cyan
docker-compose -f $composeFile build catalog.api basket.api discount.grpc ordering.api yarpapigateway shopping.web --no-cache

Write-Host "🚀 Tüm servisleri başlatıyorum..." -ForegroundColor Cyan
docker-compose -f $composeFile up -d

Write-Host "⏳ Servislerin hazır olmasını bekliyorum..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "📊 Container Durumu:" -ForegroundColor Cyan
docker-compose -f $composeFile ps

Write-Host ""
Write-Host "🧪 Servis Test'leri:" -ForegroundColor Cyan

$services = @(
    @{ Name = "Identity Server"; Url = "http://localhost:5000" },
    @{ Name = "API Gateway"; Url = "http://localhost:6004" },
    @{ Name = "Shopping Web"; Url = "http://localhost:6005" },
    @{ Name = "Catalog API"; Url = "http://localhost:6000" }
)

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5
        Write-Host "  ✅ $($service.Name) - Çalışıyor" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $($service.Name) - Cevap vermiyor" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 EShop Microservices Başlatıldı!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "🔑 Identity Server: http://localhost:5000" -ForegroundColor Yellow
Write-Host "🛒 Shopping Web:    http://localhost:6005" -ForegroundColor Yellow
Write-Host "🚪 API Gateway:     http://localhost:6004" -ForegroundColor Yellow
Write-Host ""
Write-Host "👤 Test Kullanıcıları:" -ForegroundColor White
Write-Host "  📧 admin@eshop.com / Password123!" -ForegroundColor Cyan
Write-Host "  📧 customer@eshop.com / Password123!" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎯 Şimdi http://localhost:6005 adresine gidip Sign In yapabilirsiniz!" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Sorun yaşarsanız:" -ForegroundColor White
Write-Host "  📝 Identity logs: docker-compose -f $composeFile logs identity.api" -ForegroundColor Gray
Write-Host "  📝 Web logs: docker-compose -f $composeFile logs shopping.web" -ForegroundColor Gray
Write-Host "  📝 Gateway logs: docker-compose -f $composeFile logs yarpapigateway" -ForegroundColor Gray
Write-Host ""
