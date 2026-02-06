# QUICK TEST - Current System Status
Write-Host "🔍 Quick System Test..." -ForegroundColor Green

Write-Host "`n📊 Container Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n🧪 HTTP Service Tests:" -ForegroundColor Cyan

$services = @(
    @{Name="Shopping Web"; Url="http://localhost:6005"},
    @{Name="Identity Service"; Url="http://localhost:5000"},
    @{Name="API Gateway"; Url="http://localhost:6004"},
    @{Name="Catalog API"; Url="http://localhost:6000"},
    @{Name="Basket API"; Url="http://localhost:6001"},
    @{Name="Ordering API"; Url="http://localhost:6003"}
)

$workingServices = 0
foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) - WORKING" -ForegroundColor Green
            $workingServices++
        } else {
            Write-Host "⚠️  $($service.Name) - Response: $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ $($service.Name) - NOT RESPONDING" -ForegroundColor Red
    }
}

$totalServices = $services.Count
Write-Host "`n📈 Status: $workingServices/$totalServices services responding" -ForegroundColor Cyan

if ($workingServices -ge 3) {
    Write-Host @"

🎉 SYSTEM IS WORKING!

🌐 Main URLs:
  Shopping Web:     http://localhost:6005
  Identity Service: http://localhost:5000
  API Gateway:      http://localhost:6004

🔑 Test Login:
  admin@eshop.com / Password123!

📝 Test Flow:
1. Open http://localhost:6005
2. Click "Sign In" or try Cart/Orders
3. Login with test credentials
4. Enjoy shopping!

✅ Your containers are running successfully!

"@ -ForegroundColor Green

    $openBrowser = Read-Host "🌐 Open Shopping Web now? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
        Start-Process "http://localhost:6005"
        Write-Host "✅ Browser opened!" -ForegroundColor Green
    }

} else {
    Write-Host "⚠️  Some services are not responding yet. Wait a moment and try again." -ForegroundColor Yellow
    Write-Host "Or check logs: docker-compose logs" -ForegroundColor Cyan
}

Write-Host "`n🔧 Quick test completed!" -ForegroundColor Gray
