#!/usr/bin/env pwsh

Write-Host "🔧 Identity Server - GARANTİLİ ÇÖZÜM" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

# Function to check if a port is in use
function Test-Port {
    param([int]$Port)
    try {
        $null = New-Object System.Net.Sockets.TcpClient("localhost", $Port)
        return $true
    } catch {
        return $false
    }
}

# Step 1: Complete cleanup
Write-Host "🧹 Tam temizlik yapılıyor..." -ForegroundColor Cyan
docker-compose down --remove-orphans 2>$null
docker system prune -f 2>$null

# Step 2: Check port conflicts
Write-Host "🔍 Port çakışmaları kontrol ediliyor..." -ForegroundColor Cyan
if (Test-Port 5000) {
    Write-Host "⚠️  Port 5000 kullanımda. Process'i öldürüyorum..." -ForegroundColor Yellow
    Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess -ErrorAction SilentlyContinue | Stop-Process -Force
}

# Step 3: Start infrastructure step by step
Write-Host "🏗️  Infrastructure servislerini tek tek başlatıyorum..." -ForegroundColor Cyan

Write-Host "  📊 PostgreSQL (Identity DB) başlatılıyor..." -ForegroundColor Gray
docker-compose up -d identitydb
Start-Sleep -Seconds 15

# Verify database is really ready
$dbReady = $false
$attempts = 0
while (-not $dbReady -and $attempts -lt 10) {
    try {
        docker exec identitydb pg_isready -U postgres 2>$null
        if ($LASTEXITCODE -eq 0) {
            $dbReady = $true
            Write-Host "  ✅ PostgreSQL hazır!" -ForegroundColor Green
        }
    } catch {
        $attempts++
        Write-Host "  ⏳ PostgreSQL henüz hazır değil... ($attempts/10)" -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
}

if (-not $dbReady) {
    Write-Host "❌ PostgreSQL başlatılamadı!" -ForegroundColor Red
    exit 1
}

# Step 4: Build Identity Service from scratch
Write-Host "🏗️  Identity Service'i sıfırdan build ediyorum..." -ForegroundColor Cyan
docker-compose build identity.api --no-cache --pull

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build hatası! Dockerfile kontrol ediliyor..." -ForegroundColor Red
    
    # Try with debug dockerfile
    Write-Host "🔧 Debug Dockerfile ile deniyorum..." -ForegroundColor Yellow
    docker build -f Services/Identity/Identity.API/Dockerfile.debug -t identityapi-debug .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Debug build başarılı!" -ForegroundColor Green
    } else {
        Write-Host "❌ Build tamamen başarısız!" -ForegroundColor Red
        exit 1
    }
}

# Step 5: Start Identity Service and monitor
Write-Host "🚀 Identity Service'i başlatıyorum ve izliyorum..." -ForegroundColor Green

# Start in background
docker-compose up -d identity.api

# Monitor for 30 seconds
Write-Host "📊 30 saniye boyunca container durumunu izliyorum..." -ForegroundColor Yellow
for ($i = 1; $i -le 30; $i++) {
    $containerStatus = docker-compose ps -q identity.api | ForEach-Object { docker inspect $_ --format '{{.State.Status}}' }
    
    if ($containerStatus -eq "running") {
        Write-Host "  [$i/30] ✅ Container çalışıyor" -ForegroundColor Green
        
        # Test health endpoint
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:5000/health" -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) {
                Write-Host "🎉 BAŞARILI! Identity Server çalışıyor!" -ForegroundColor Green
                Write-Host "🔗 Test URL: http://localhost:5000" -ForegroundColor Cyan
                break
            }
        } catch {
            # Health endpoint not ready yet, continue monitoring
        }
    } else {
        Write-Host "  [$i/30] ❌ Container durumu: $containerStatus" -ForegroundColor Red
        
        if ($containerStatus -eq "exited") {
            Write-Host "💥 Container çıktı! Log'ları gösteriyorum:" -ForegroundColor Red
            docker-compose logs --tail=20 identity.api
            break
        }
    }
    
    Start-Sleep -Seconds 1
}

# Final status check
Write-Host ""
Write-Host "📊 Final Durum Raporu:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

$finalStatus = docker-compose ps identity.api
Write-Host $finalStatus

if ($finalStatus -match "Up") {
    Write-Host ""
    Write-Host "🎉 BAŞARILI! Identity Server çalışıyor!" -ForegroundColor Green
    Write-Host "🔗 Test URL'leri:" -ForegroundColor White
    Write-Host "  Health: http://localhost:5000/health" -ForegroundColor Cyan
    Write-Host "  Debug:  http://localhost:5000/debug/config" -ForegroundColor Cyan
    Write-Host "  Main:   http://localhost:5000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🛒 Şimdi Shopping Web'i başlatabilirsiniz:" -ForegroundColor White
    Write-Host "  docker-compose up -d" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ HALA SORUN VAR!" -ForegroundColor Red
    Write-Host "Log'ları kontrol edin:" -ForegroundColor White
    Write-Host "  docker-compose logs identity.api" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Manuel debug için:" -ForegroundColor White
    Write-Host "  docker run -it --rm -p 5000:8080 identityapi-debug" -ForegroundColor Gray
}

Write-Host ""
