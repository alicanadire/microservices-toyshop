# ToyShop Docker Build Test Script

Write-Host "=== ToyShop Docker Build Test ===" -ForegroundColor Green

# Test individual service builds
Write-Host "`nTesting Discount.Grpc build..." -ForegroundColor Yellow
cd src
docker build -f Services/Discount/Discount.Grpc/Dockerfile -t discount-test .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Discount.Grpc build successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Discount.Grpc build failed!" -ForegroundColor Red
    exit 1
}

# Test full docker-compose build
Write-Host "`nTesting full docker-compose build..." -ForegroundColor Yellow
docker-compose build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Full docker-compose build successful!" -ForegroundColor Green
    
    # Start services
    Write-Host "`nStarting services..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All services started successfully!" -ForegroundColor Green
        Write-Host "`nServices running:" -ForegroundColor Cyan
        docker-compose ps
        
        Write-Host "`nToyShop is ready! 🧸" -ForegroundColor Green
        Write-Host "Access URLs:" -ForegroundColor Yellow
        Write-Host "- Shopping Web: https://localhost:6065" -ForegroundColor White
        Write-Host "- API Gateway: https://localhost:6064" -ForegroundColor White
        Write-Host "- Catalog API: https://localhost:6060" -ForegroundColor White
        Write-Host "- Basket API: https://localhost:6061" -ForegroundColor White
        Write-Host "- Discount gRPC: https://localhost:6062" -ForegroundColor White
        Write-Host "- Ordering API: https://localhost:6063" -ForegroundColor White
        Write-Host "- RabbitMQ Management: http://localhost:15672" -ForegroundColor White
    } else {
        Write-Host "❌ Service startup failed!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Docker-compose build failed!" -ForegroundColor Red
}

cd ..
