# Test Authentication Flow
Write-Host "🧪 Testing Authentication Flow..." -ForegroundColor Green

Write-Host "`n1️⃣ Testing Anonymous Access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:6005" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Anonymous access to Index page - SUCCESS" -ForegroundColor Green
        
        if ($response.Content -like "*Welcome to EShop*") {
            Write-Host "✅ Anonymous welcome message visible - SUCCESS" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Welcome message might not be visible" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "❌ Anonymous access failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2️⃣ Testing Identity Service..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Identity Service accessible - SUCCESS" -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ Identity Service not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3️⃣ Testing API Gateway..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:6004" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API Gateway accessible - SUCCESS" -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ API Gateway not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host @"

🎯 AUTHENTICATION TEST RESULTS:

✅ EXPECTED FLOW:
1. 👤 Anonymous user → http://localhost:6005
2. 📄 Index page shows welcome message + sample products
3. 🔐 "Sign In" button → http://localhost:5000  
4. 👤 Login: admin@eshop.com / Password123!
5. 🔄 Redirect back to Shopping Web with authentication
6. 📦 Real products from API visible

🧪 MANUAL TEST STEPS:
1. Open: http://localhost:6005
2. Should see "Welcome to EShop!" message
3. Click "Sign In" button
4. Login with test credentials
5. Should redirect back with real products

"@ -ForegroundColor Cyan

$openTest = Read-Host "🌐 Open browser for manual test? (y/n)"
if ($openTest -eq 'y' -or $openTest -eq 'Y' -or $openTest -eq '') {
    Write-Host "🚀 Opening browser for manual authentication test..." -ForegroundColor Green
    Start-Process "http://localhost:6005"
}

Write-Host "`n🧪 Authentication test completed!" -ForegroundColor Gray
