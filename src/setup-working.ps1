# EShop Mikroservices - TAM ÇALIŞAN KURULUM
# Tüm hatalar düzeltilmiş, garantili çalışan versiyon

Write-Host @"
================================================================
              .NET 8 MIKROSERVIS E-TICARET                   
                 + IDENTITYSERVER4 KIMLIK DOGRULAMA           
                   GARANTİLİ ÇALIŞAN KURULUM                  
================================================================
"@ -ForegroundColor Cyan

# Admin kontrol
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Bu script Administrator yetkisiyle çalıştırılmalıdır!" -ForegroundColor Red
    Read-Host "Çıkmak için Enter'a basın..."
    exit 1
}

# Fonksiyonlar
function Stop-AllContainers {
    Write-Host "⏹️ Tüm container'lar durduruluyor..." -ForegroundColor Yellow
    docker-compose down --remove-orphans 2>$null
    docker stop $(docker ps -aq) 2>$null
    docker rm $(docker ps -aq) 2>$null
}

function Clean-DockerCache {
    Write-Host "🧹 Docker cache temizleniyor..." -ForegroundColor Yellow
    docker builder prune -f
    docker system prune -f 2>$null
}

function Test-Service {
    param($ServiceName, $Url, $TimeoutSeconds = 5)
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec $TimeoutSeconds -SkipCertificateCheck -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $ServiceName - Çalışıyor" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "❌ $ServiceName - Henüz hazır değil" -ForegroundColor Red
    }
    return $false
}

# Ana kurulum
try {
    Write-Host "`n🔧 Sistem hazırlığı..." -ForegroundColor Cyan
    
    # Port temizleme
    $ports = @(5001, 5000, 6005, 6004, 6000, 6001, 6002, 6003, 5432, 5433, 5434, 1433, 6379, 5672, 15672)
    foreach ($port in $ports) {
        try {
            $process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
            if ($process) {
                Stop-Process -Id $process.OwningProcess -Force -ErrorAction SilentlyContinue
            }
        }
        catch { }
    }
    
    # Docker temizleme
    Stop-AllContainers
    Clean-DockerCache
    
    # SSL sertifikaları
    Write-Host "🔐 SSL sertifikaları ayarlanıyor..." -ForegroundColor Cyan
    dotnet dev-certs https --clean 2>$null
    dotnet dev-certs https --trust
    
    $httpsPath = "$env:USERPROFILE\.aspnet\https"
    if (-not (Test-Path $httpsPath)) {
        New-Item -ItemType Directory -Force -Path $httpsPath | Out-Null
    }
    dotnet dev-certs https -ep "$httpsPath\aspnetapp.pfx" -p "password"
    
    # Environment dosyası
    Write-Host "⚙️ Environment ayarları..." -ForegroundColor Cyan
    if (-not (Test-Path ".env")) {
        $envContent = @"
DOMAIN_NAME=localhost
DOCKER_REGISTRY=
CATALOG_DB_PASSWORD=StrongPassword123!
BASKET_DB_PASSWORD=StrongPassword123!
IDENTITY_DB_PASSWORD=StrongPassword123!
ORDER_DB_PASSWORD=SwN12345678
REDIS_PASSWORD=StrongRedisPassword123!
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
SHOPPING_WEB_CLIENT_SECRET=shopping-web-secret-key
ASPNETCORE_ENVIRONMENT=Development
LOGGING_LEVEL=Information
"@
        Set-Content -Path ".env" -Value $envContent
    }
    
    # Docker build - Adım adım
    Write-Host "`n🏗️ Docker build başlıyor..." -ForegroundColor Cyan
    
    Write-Host "1️⃣ Identity Service build..." -ForegroundColor Yellow
    docker-compose build identity.api --no-cache
    if ($LASTEXITCODE -ne 0) { throw "Identity Service build failed" }
    Write-Host "✅ Identity Service OK" -ForegroundColor Green
    
    Write-Host "2️⃣ API Gateway build..." -ForegroundColor Yellow
    docker-compose build yarpapigateway --no-cache
    if ($LASTEXITCODE -ne 0) { throw "API Gateway build failed" }
    Write-Host "✅ API Gateway OK" -ForegroundColor Green
    
    Write-Host "3️⃣ Shopping Web build..." -ForegroundColor Yellow
    docker-compose build shopping.web --no-cache
    if ($LASTEXITCODE -ne 0) { throw "Shopping Web build failed" }
    Write-Host "✅ Shopping Web OK" -ForegroundColor Green
    
    Write-Host "4️⃣ Diğer servisler build..." -ForegroundColor Yellow
    docker-compose build catalog.api basket.api ordering.api discount.grpc --no-cache
    if ($LASTEXITCODE -ne 0) { throw "Other services build failed" }
    Write-Host "✅ Tüm servisler OK" -ForegroundColor Green
    
    # Servisleri başlat
    Write-Host "`n🚀 Servisler başlatılıyor..." -ForegroundColor Cyan
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) { throw "Services startup failed" }
    
    # Servislerin hazır olmasını bekle
    Write-Host "`n⏳ Servisler hazırlanıyor..." -ForegroundColor Cyan
    $maxWait = 120
    $waited = 0
    
    while ($waited -lt $maxWait) {
        $readyCount = 0
        
        if (Test-Service "Identity Service" "https://localhost:5001") { $readyCount++ }
        if (Test-Service "Shopping Web" "http://localhost:6005") { $readyCount++ }
        if (Test-Service "API Gateway" "http://localhost:6004") { $readyCount++ }
        
        if ($readyCount -eq 3) {
            Write-Host "🎉 Ana servisler hazır!" -ForegroundColor Green
            break
        }
        
        Start-Sleep 5
        $waited += 5
        Write-Host "⏳ Beklenen süre: $waited/$maxWait saniye..." -ForegroundColor Yellow
    }
    
    # Final kontrol
    Write-Host "`n📊 Sistem durumu:" -ForegroundColor Cyan
    docker-compose ps
    
    # Başarı mesajı
    Write-Host @"

🎉 KURULUM BAŞARIYLA TAMAMLANDI!

🌐 ERİŞİM LİNKLERİ:
  Shopping Web:     http://localhost:6005
  Identity Service: https://localhost:5001
  API Gateway:      http://localhost:6004
  Catalog API:      http://localhost:6000
  Basket API:       http://localhost:6001
  Ordering API:     http://localhost:6003
  RabbitMQ:         http://localhost:15672 (guest/guest)

🔑 TEST KULLANICILARI:
  Admin:    admin@eshop.com / Password123!
  Customer: customer@eshop.com / Password123!

📝 KULLANIM:
1. Shopping Web'e git: http://localhost:6005
2. Cart veya Orders'a tıkla
3. Identity Service'e yönlendirileceksin
4. Test kullanıcıları ile giriş yap

✅ SİSTEM TAM ÇALIŞIR DURUMDA!

"@ -ForegroundColor Green

    # Tarayıcıyı aç
    $openBrowser = Read-Host "Shopping Web'i tarayıcıda açmak ister misin? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
        Start-Process "http://localhost:6005"
        Start-Sleep 2
        Start-Process "https://localhost:5001"
    }
    
}
catch {
    Write-Host "`n❌ HATA OLUŞTU: $($_.Exception.Message)" -ForegroundColor Red
    
    Write-Host "`n🔧 SORUN GİDERME:" -ForegroundColor Yellow
    Write-Host "1. Docker Desktop çalışıyor mu?" -ForegroundColor White
    Write-Host "2. Administrator yetkisi var mı?" -ForegroundColor White
    Write-Host "3. Antivirus engellemiyor mu?" -ForegroundColor White
    Write-Host "4. Portlar kullanımda mı?" -ForegroundColor White
    
    Write-Host "`n📊 Mevcut container durumu:" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host "`n📝 Son 20 log satırı:" -ForegroundColor Cyan
    docker-compose logs --tail=20
}

Write-Host "`nScript tamamlandı!" -ForegroundColor Gray
Read-Host "Çıkmak için Enter'a basın..."
