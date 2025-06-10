# RESTART WITH 401 FIX
Write-Host "🔧 Restarting Shopping Web with 401 fix..." -ForegroundColor Green

# Shopping Web'i yeniden build et
Write-Host "🏗️ Rebuilding Shopping Web with 401 fix..." -ForegroundColor Yellow
docker-compose build shopping.web --no-cache

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Shopping Web'i yeniden başlat
Write-Host "🔄 Restarting Shopping Web..." -ForegroundColor Yellow
docker-compose up -d shopping.web

Write-Host "⏳ Waiting for Shopping Web to start..." -ForegroundColor Yellow
Start-Sleep 15

# Test anonymous access
Write-Host "🧪 Testing anonymous access..." -ForegroundColor Cyan
$maxRetries = 6
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:6005" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Shopping Web responding successfully!" -ForegroundColor Green
            
            if ($response.Content -like "*Welcome to EShop*") {
                Write-Host "✅ Anonymous welcome message working!" -ForegroundColor Green
            }
            break
        }
    }
    catch {
        $retryCount++
        Write-Host "⏳ Retry $retryCount/$maxRetries - Still starting..." -ForegroundColor Yellow
        Start-Sleep 5
    }
}

if ($retryCount -ge $maxRetries) {
    Write-Host "❌ Shopping Web not responding after restart" -ForegroundColor Red
    Write-Host "🔍 Checking logs..." -ForegroundColor Yellow
    docker-compose logs shopping.web --tail=20
} else {
    Write-Host @"

🎉 401 ERROR FIXED & RESTARTED!

✅ EXPECTED BEHAVIOR:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 ANONYMOUS USERS:
  → http://localhost:6005 
  → See "Welcome to EShop!" message
  → See sample products
  → "Sign In" button available

🔐 AUTHENTICATED USERS:  
  → Login at http://localhost:5000
  → Redirect back to Shopping Web
  → See real products from API
  → Full shopping functionality

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔑 TEST CREDENTIALS:
  Admin:    admin@eshop.com / Password123!
  Customer: customer@eshop.com / Password123!

"@ -ForegroundColor Green
}

# Container status
Write-Host "`n📊 Container Status:" -ForegroundColor Cyan
docker-compose ps

$openBrowser = Read-Host "`n🌐 Test the fix in browser? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
    Write-Host "🚀 Opening browser for 401 fix test..." -ForegroundColor Green
    Start-Process "http://localhost:6005"
    Write-Host "✅ Browser opened! You should see the welcome message instead of 401 error." -ForegroundColor Green
}

Write-Host "`n🔧 401 fix and restart completed!" -ForegroundColor Gray
