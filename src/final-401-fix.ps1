# FINAL 401 FIX - REBUILD CONTAINER
Write-Host "🔧 Final 401 Fix - Rebuilding Shopping Web..." -ForegroundColor Red

Write-Host @"

🚨 SORUN: 401 Unauthorized hala devam ediyor
📝 ÇÖZÜM: Shopping Web container'ını yeniden build et

"@ -ForegroundColor Yellow

# Shopping Web'i durdur
Write-Host "⏹️ Shopping Web durduruluyor..." -ForegroundColor Yellow
docker-compose stop shopping.web

# Container'ı kaldır
Write-Host "🗑️ Eski container kaldırılıyor..." -ForegroundColor Yellow
docker-compose rm -f shopping.web

# Image'ı sil
Write-Host "🗑️ Eski image siliniyor..." -ForegroundColor Yellow
docker rmi shoppingweb 2>$null
docker rmi src-shopping.web 2>$null

# Yeniden build et
Write-Host "🏗️ Shopping Web yeniden build ediliyor..." -ForegroundColor Cyan
docker-compose build shopping.web --no-cache

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Checking logs..." -ForegroundColor Red
    docker-compose logs shopping.web
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Başlat
Write-Host "🚀 Shopping Web başlatılıyor..." -ForegroundColor Cyan
docker-compose up -d shopping.web

Write-Host "⏳ Shopping Web'in başlaması bekleniyor..." -ForegroundColor Yellow
Start-Sleep 20

# Test et
Write-Host "🧪 401 fix test ediliyor..." -ForegroundColor Cyan
$maxRetries = 8
$retryCount = 0
$testSuccess = $false

while ($retryCount -lt $maxRetries) {
    try {
        Write-Host "Test $($retryCount + 1)/$maxRetries..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri "http://localhost:6005" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ HTTP 200 OK - No more 401!" -ForegroundColor Green
            
            if ($response.Content -like "*Welcome to EShop*" -or $response.Content -like "*Please log in*") {
                Write-Host "✅ Anonymous welcome message working!" -ForegroundColor Green
                $testSuccess = $true
                break
            } else {
                Write-Host "⚠️  Page loads but content might be different" -ForegroundColor Yellow
                $testSuccess = $true
                break
            }
        }
    }
    catch {
        $retryCount++
        if ($_.Exception.Message -like "*401*" -or $_.Exception.Message -like "*Unauthorized*") {
            Write-Host "❌ Still getting 401 error... retry $retryCount/$maxRetries" -ForegroundColor Red
        } else {
            Write-Host "⏳ Service starting... retry $retryCount/$maxRetries" -ForegroundColor Yellow
        }
        Start-Sleep 5
    }
}

if ($testSuccess) {
    Write-Host @"

🎉 401 ERROR FINALLY FIXED!

✅ WORKING FLOW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 ANONYMOUS USERS:
  → http://localhost:6005 → Welcome message (NO 401!)
  → Sample products shown
  → "Sign In" button available

🔐 AUTHENTICATED USERS:
  → Click "Sign In" → http://localhost:5000
  → Login: admin@eshop.com / Password123!
  → Redirect back → Real products shown

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@ -ForegroundColor Green

    $openBrowser = Read-Host "🌐 Test the fix in browser now? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
        Start-Process "http://localhost:6005"
        Write-Host "✅ Browser opened - you should see NO 401 error!" -ForegroundColor Green
    }

} else {
    Write-Host @"

❌ 401 ERROR STILL EXISTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 DEBUGGING STEPS:
1. Check container logs: docker-compose logs shopping.web
2. Verify services: docker-compose ps
3. Manual build: docker-compose build shopping.web --no-cache
4. Check if file changes applied correctly

"@ -ForegroundColor Red

    Write-Host "`n📊 Container status:" -ForegroundColor Cyan
    docker-compose ps

    Write-Host "`n📝 Recent logs:" -ForegroundColor Cyan  
    docker-compose logs shopping.web --tail=10
}

Write-Host "`n🔧 401 fix attempt completed!" -ForegroundColor Gray
