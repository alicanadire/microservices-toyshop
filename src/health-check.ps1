#!/usr/bin/env pwsh

Write-Host "🏥 EShop Microservices Health Check" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Services to check
$services = @(
    @{ Name = "Identity Service"; Url = "http://localhost:5000"; Container = "identity.api" },
    @{ Name = "API Gateway"; Url = "http://localhost:6004"; Container = "yarpapigateway" },
    @{ Name = "Shopping Web"; Url = "http://localhost:6005"; Container = "shopping.web" },
    @{ Name = "Catalog API"; Url = "http://localhost:6000"; Container = "catalog.api" },
    @{ Name = "Basket API"; Url = "http://localhost:6001"; Container = "basket.api" },
    @{ Name = "Ordering API"; Url = "http://localhost:6003"; Container = "ordering.api" },
    @{ Name = "Discount gRPC"; Url = "http://localhost:6002"; Container = "discount.grpc" }
)

Write-Host "🐳 Docker Container Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "🌐 Service Health Check:" -ForegroundColor Cyan

$healthyServices = 0
$totalServices = $services.Count

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.Url -Method Get -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ $($service.Name) - Healthy" -ForegroundColor Green
            $healthyServices++
        } else {
            Write-Host "  ⚠️  $($service.Name) - Responding but unhealthy (Status: $($response.StatusCode))" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ❌ $($service.Name) - Not responding" -ForegroundColor Red
        Write-Host "     Container status:" -ForegroundColor Gray
        docker-compose ps $service.Container
    }
}

Write-Host ""
Write-Host "📊 Health Summary: $healthyServices/$totalServices services healthy" -ForegroundColor $(if ($healthyServices -eq $totalServices) { "Green" } elseif ($healthyServices -gt 0) { "Yellow" } else { "Red" })

if ($healthyServices -eq $totalServices) {
    Write-Host "🎉 All services are healthy! You can access the application at:" -ForegroundColor Green
    Write-Host "   🛒 Shopping Web: http://localhost:6005" -ForegroundColor Cyan
} elseif ($healthyServices -gt 0) {
    Write-Host "⚠️  Some services are not responding. Check the logs:" -ForegroundColor Yellow
    Write-Host "   docker-compose logs [service-name]" -ForegroundColor Gray
} else {
    Write-Host "❌ No services are responding. Try restarting:" -ForegroundColor Red
    Write-Host "   docker-compose down && docker-compose up -d" -ForegroundColor Gray
}

Write-Host ""
