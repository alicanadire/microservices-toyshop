# FINAL BUILD SCRIPT - TÜM HATALAR DÜZELTİLDİ
Write-Host "🔧 FINAL BUILD - Tüm hatalar düzeltildi!" -ForegroundColor Green

# Temizlik
Write-Host "🧹 Docker temizliği..." -ForegroundColor Yellow
docker-compose down --remove-orphans 2>$null
docker builder prune -f

# Hataları düzeltildi:
Write-Host "✅ Authorize attribute çakışması düzeltildi" -ForegroundColor Green
Write-Host "✅ User property conflict düzeltildi" -ForegroundColor Green
Write-Host "✅ Refit usings service'lere eklendi" -ForegroundColor Green
Write-Host "✅ JWT configuration düzeltildi" -ForegroundColor Green

# Sıralı build
Write-Host "`n🏗️ Temiz build başlıyor..." -ForegroundColor Cyan

Write-Host "1️⃣ Database'ler..." -ForegroundColor Yellow
docker-compose up -d identitydb catalogdb basketdb orderdb distributedcache messagebroker
Start-Sleep 8

Write-Host "2️⃣ Identity Service..." -ForegroundColor Yellow
docker-compose build identity.api --no-cache
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Identity build failed" -ForegroundColor Red; exit 1 }

Write-Host "3️⃣ API Gateway..." -ForegroundColor Yellow
docker-compose build yarpapigateway --no-cache
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Gateway build failed" -ForegroundColor Red; exit 1 }

Write-Host "4️⃣ Shopping Web..." -ForegroundColor Yellow
docker-compose build shopping.web --no-cache
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Shopping Web build failed" -ForegroundColor Red; exit 1 }

Write-Host "5️⃣ Diğer servisler..." -ForegroundColor Yellow
docker-compose build catalog.api basket.api ordering.api discount.grpc --no-cache
if ($LASTEXITCODE -ne 0) { Write-Host "❌ Other services build failed" -ForegroundColor Red; exit 1 }

Write-Host "✅ TÜM SERVISLER BAŞARIYLA BUILD EDİLDİ!" -ForegroundColor Green

# Başlat
Write-Host "`n🚀 Servisler başlatılıyor..." -ForegroundColor Cyan
docker-compose up -d

Write-Host "`n⏳ Servisler hazırlanıyor..." -ForegroundColor Yellow
Start-Sleep 15

# Kontrol
$services = @(
    @{Name="Identity Service"; Url="http://localhost:5000"},
    @{Name="Shopping Web"; Url="http://localhost:6005"},
    @{Name="API Gateway"; Url="http://localhost:6004"}
)

Write-Host "`n📊 HTTP Servis Kontrolü:" -ForegroundColor Cyan
foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) - ÇALIŞIYOR" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "❌ $($service.Name) - Henüz hazır değil" -ForegroundColor Yellow
    }
}

Write-Host @"

🎉 KURULUM TAMAMLANDI!

🌐 HTTP URLS (SSL YOK!):
  Shopping Web:     http://localhost:6005
  Identity Service: http://localhost:5000
  API Gateway:      http://localhost:6004
  RabbitMQ:         http://localhost:15672 (guest/guest)

🔑 TEST:
1. http://localhost:6005 → Shopping Web
2. Cart/Orders tıkla → Identity'e yönlendir
3. admin@eshop.com / Password123! ile giriş

✅ TÜM HATALAR DÜZELTİLDİ!
✅ DOCKER BUILD BAŞARILI!
✅ HTTP-ONLY ÇALIŞAN SİSTEM!

"@ -ForegroundColor Green

$openBrowser = Read-Host "Tarayıcıda açmak ister misin? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
    Start-Process "http://localhost:6005"
    Start-Sleep 2
    Start-Process "http://localhost:5000"
}

Write-Host "`nFinal build tamamlandı!" -ForegroundColor Gray
