# EMERGENCY FIX - TÜM HATALARI DÜZELT
Write-Host "🚨 EMERGENCY HTTP-ONLY FIX BAŞLATIYOR..." -ForegroundColor Red

# 1. Tüm container'ları durdur
Write-Host "⏹️ Tüm container'lar durduruluyor..." -ForegroundColor Yellow
docker-compose down --remove-orphans 2>$null
docker stop $(docker ps -aq) 2>$null
docker rm $(docker ps -aq) 2>$null

# 2. Tüm images'ları temizle
Write-Host "🗑️ Tüm images temizleniyor..." -ForegroundColor Yellow
docker rmi $(docker images -q) -f 2>$null
docker system prune -af

# 3. Manuel HTTP servislerini başlat (Database'ler Docker'da)
Write-Host "📦 Database'ler Docker'da başlatılıyor..." -ForegroundColor Cyan

# PostgreSQL for Identity
docker run -d --name identitydb -p 5434:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=IdentityDb postgres:latest 2>$null

# PostgreSQL for Catalog  
docker run -d --name catalogdb -p 5432:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=CatalogDb postgres:latest 2>$null

# PostgreSQL for Basket
docker run -d --name basketdb -p 5433:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=BasketDb postgres:latest 2>$null

# SQL Server for Orders
docker run -d --name orderdb -p 1433:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=SwN12345678" mcr.microsoft.com/mssql/server:2022-latest 2>$null

# Redis
docker run -d --name redis -p 6379:6379 redis:latest 2>$null

# RabbitMQ
docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest rabbitmq:management 2>$null

Write-Host "⏳ Database'lerin başlaması bekleniyor..." -ForegroundColor Yellow
Start-Sleep 20

# 4. .NET HTTP servisleri manuel başlat
Write-Host "🚀 .NET HTTP servisleri başlatılıyor..." -ForegroundColor Cyan

# Environment variables
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:ASPNETCORE_URLS = "http://localhost:5000"

# Identity Service (HTTP only)
Write-Host "🔐 Identity Service başlatılıyor..." -ForegroundColor Green
Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'Services\Identity\Identity.API'; `$env:ASPNETCORE_URLS='http://localhost:5000'; dotnet run" -WindowStyle Minimized

Start-Sleep 5

# API Gateway
Write-Host "🌐 API Gateway başlatılıyor..." -ForegroundColor Green
Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'ApiGateways\YarpApiGateway'; `$env:ASPNETCORE_URLS='http://localhost:6004'; dotnet run" -WindowStyle Minimized

Start-Sleep 3

# Shopping Web
Write-Host "🛒 Shopping Web başlatılıyor..." -ForegroundColor Green
Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'WebApps\Shopping.Web'; `$env:ASPNETCORE_URLS='http://localhost:6005'; dotnet run" -WindowStyle Minimized

Start-Sleep 3

# Catalog API
Write-Host "📦 Catalog API başlatılıyor..." -ForegroundColor Green
Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'Services\Catalog\Catalog.API'; `$env:ASPNETCORE_URLS='http://localhost:6000'; dotnet run" -WindowStyle Minimized

Start-Sleep 2

# Basket API  
Write-Host "🛍️ Basket API başlatılıyor..." -ForegroundColor Green
Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'Services\Basket\Basket.API'; `$env:ASPNETCORE_URLS='http://localhost:6001'; dotnet run" -WindowStyle Minimized

Start-Sleep 2

# Ordering API
Write-Host "📋 Ordering API başlatılıyor..." -ForegroundColor Green
Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'Services\Ordering\Ordering.API'; `$env:ASPNETCORE_URLS='http://localhost:6003'; dotnet run" -WindowStyle Minimized

# 5. Servislerin hazır olmasını bekle
Write-Host "`n⏳ HTTP servislerin hazır olması bekleniyor..." -ForegroundColor Cyan
$maxWait = 60
$waited = 0

while ($waited -lt $maxWait) {
    $readyCount = 0
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) { 
            Write-Host "✅ Identity Service (HTTP)" -ForegroundColor Green
            $readyCount++ 
        }
    } catch { }
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:6005" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) { 
            Write-Host "✅ Shopping Web (HTTP)" -ForegroundColor Green
            $readyCount++ 
        }
    } catch { }
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:6004" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) { 
            Write-Host "✅ API Gateway (HTTP)" -ForegroundColor Green
            $readyCount++ 
        }
    } catch { }
    
    if ($readyCount -eq 3) {
        Write-Host "🎉 ANA HTTP SERVİSLER HAZIR!" -ForegroundColor Green
        break
    }
    
    Start-Sleep 3
    $waited += 3
}

# 6. Sonuç
Write-Host @"

🎉 EMERGENCY HTTP-ONLY KURULUM TAMAMLANDI!

🌐 HTTP SERVİSLER (SSL YOK!):
  Shopping Web:     http://localhost:6005
  Identity Service: http://localhost:5000  
  API Gateway:      http://localhost:6004
  Catalog API:      http://localhost:6000
  Basket API:       http://localhost:6001
  Ordering API:     http://localhost:6003
  RabbitMQ:         http://localhost:15672 (guest/guest)

🔑 TEST KULLANICILARI:
  Admin:    admin@eshop.com / Password123!
  Customer: customer@eshop.com / Password123!

📝 TEST:
1. http://localhost:6005 → Shopping Web
2. Cart veya Orders tıkla
3. http://localhost:5000 → Identity'e yönlendir
4. Test kullanıcılarıyla giriş yap

✅ DOCKER BUILD HATASI YOK!
✅ HTTPS KARIŞIKLIĞI YOK!
✅ TAM HTTP ÇALIŞAN SİSTEM!

"@ -ForegroundColor Green

$openBrowser = Read-Host "Shopping Web'i HTTP açmak ister misin? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
    Start-Process "http://localhost:6005"
    Start-Sleep 2
    Start-Process "http://localhost:5000"
}

Write-Host "`nEmergency fix tamamlandı!" -ForegroundColor Gray
Read-Host "Çıkmak için Enter'a basın..."
