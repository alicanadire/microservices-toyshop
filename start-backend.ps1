# ToyShop Backend Services Starter Script
# Bu script backend mikroservisleri sırayla başlatır

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "ToyShop Backend Services Starter" -ForegroundColor Cyan  
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# .NET SDK kontrolü
Write-Host "🔍 .NET SDK kontrol ediliyor..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET SDK bulundu: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET SDK bulunamadı! Lütfen .NET 8 SDK'yı yükleyin." -ForegroundColor Red
    Write-Host "İndirme linki: https://dotnet.microsoft.com/download" -ForegroundColor Blue
    Read-Host "Devam etmek için Enter'a basın"
    exit 1
}

Write-Host ""

# Docker kontrolü
Write-Host "🔍 Docker kontrol ediliyor..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker bulundu: $dockerVersion" -ForegroundColor Green
    $useDocker = Read-Host "Docker kullanarak tüm servisleri başlatmak istiyor musunuz? (y/n) [Önerilen]"
} catch {
    Write-Host "⚠️  Docker bulunamadı, manuel başlatma yapılacak." -ForegroundColor Yellow
    $useDocker = "n"
}

Write-Host ""

if ($useDocker -eq "y" -or $useDocker -eq "Y") {
    # Docker ile başlatma
    Write-Host "🐳 Docker Compose ile backend servisleri başlatılıyor..." -ForegroundColor Cyan
    Set-Location "src"
    
    try {
        # Eski container'ları temizle
        Write-Host "🧹 Eski container'lar temizleniyor..." -ForegroundColor Yellow
        docker-compose down 2>$null
        
        # Servisleri başlat
        Write-Host "🚀 Backend servisleri başlatılıyor..." -ForegroundColor Yellow
        docker-compose up -d
        
        Write-Host ""
        Write-Host "✅ Docker servisleri başlatıldı!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Servis URL'leri:" -ForegroundColor Cyan
        Write-Host "- Shopping Web: https://localhost:6065" -ForegroundColor White
        Write-Host "- API Gateway: https://localhost:6064" -ForegroundColor White
        Write-Host "- Catalog API: http://localhost:6000" -ForegroundColor White
        Write-Host "- Basket API: http://localhost:6001" -ForegroundColor White
        Write-Host "- Ordering API: http://localhost:6003" -ForegroundColor White
        Write-Host ""
        Write-Host "🔍 Container durumunu kontrol etmek için: docker ps" -ForegroundColor Blue
        
    } catch {
        Write-Host "❌ Docker başlatma hatası: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Manuel başlatma yapılacak..." -ForegroundColor Yellow
        $useDocker = "n"
    }
    
    Set-Location ".."
}

if ($useDocker -ne "y" -and $useDocker -ne "Y") {
    # Manuel başlatma
    Write-Host "🛠️  Manuel başlatma seçildi..." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Bu işlem 5 ayrı terminal penceresi açacak." -ForegroundColor Yellow
    $continue = Read-Host "Devam etmek istiyor musunuz? (y/n)"
    
    if ($continue -eq "y" -or $continue -eq "Y") {
        Write-Host ""
        Write-Host "🚀 Mikroservisler başlatılıyor..." -ForegroundColor Cyan
        
        # Catalog Service
        Write-Host "📦 Catalog Service başlatılıyor..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'src\Services\Catalog\Catalog.API'; Write-Host '🏪 Catalog Service - Port 6000' -ForegroundColor Green; dotnet run"
        Start-Sleep 2
        
        # Basket Service  
        Write-Host "🛒 Basket Service başlatılıyor..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'src\Services\Basket\Basket.API'; Write-Host '🛒 Basket Service - Port 6001' -ForegroundColor Green; dotnet run"
        Start-Sleep 2
        
        # Discount Service
        Write-Host "💰 Discount Service başlatılıyor..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'src\Services\Discount\Discount.Grpc'; Write-Host '💰 Discount Service - Port 6002' -ForegroundColor Green; dotnet run"
        Start-Sleep 2
        
        # Ordering Service
        Write-Host "📋 Ordering Service başlatılıyor..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'src\Services\Ordering\Ordering.API'; Write-Host '📋 Ordering Service - Port 6003' -ForegroundColor Green; dotnet run"
        Start-Sleep 2
        
        # API Gateway
        Write-Host "🌐 API Gateway başlatılıyor..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'src\ApiGateways\YarpApiGateway'; Write-Host '🌐 API Gateway - Port 6004' -ForegroundColor Green; dotnet run"
        Start-Sleep 2
        
        # Shopping Web (isteğe bağlı)
        $startWeb = Read-Host "Shopping.Web uygulamasını da başlatmak istiyor musunuz? (y/n)"
        if ($startWeb -eq "y" -or $startWeb -eq "Y") {
            Write-Host "🛍️  Shopping Web başlatılıyor..." -ForegroundColor Yellow
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'src\WebApps\Shopping.Web'; Write-Host '🛍️ Shopping Web - Port 6005' -ForegroundColor Green; dotnet run"
        }
        
        Write-Host ""
        Write-Host "✅ Tüm servisler başlatıldı!" -ForegroundColor Green
        Write-Host "⏱️  Servislerin tam olarak hazır olması 30-60 saniye sürebilir." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Servis URL'leri:" -ForegroundColor Cyan
        Write-Host "- API Gateway: https://localhost:6004" -ForegroundColor White
        Write-Host "- Catalog API: http://localhost:6000" -ForegroundColor White
        Write-Host "- Basket API: http://localhost:6001" -ForegroundColor White  
        Write-Host "- Discount gRPC: http://localhost:6002" -ForegroundColor White
        Write-Host "- Ordering API: http://localhost:6003" -ForegroundColor White
        if ($startWeb -eq "y" -or $startWeb -eq "Y") {
            Write-Host "- Shopping Web: https://localhost:6005" -ForegroundColor White
        }
    } else {
        Write-Host "❌ İşlem iptal edildi." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🔍 Frontend durumunu kontrol etmek için:" -ForegroundColor Cyan
Write-Host "http://localhost:3000/api/health" -ForegroundColor Blue
Write-Host ""
Write-Host "📖 Daha fazla bilgi için: API_SORUN_COZUM_KILAVUZU.md" -ForegroundColor Blue
Write-Host ""

Read-Host "Çıkmak için Enter'a basın"
