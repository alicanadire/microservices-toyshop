# Quick fix for JWT configuration error in API Gateway
Write-Host "🔧 Fixing JWT configuration error in API Gateway..." -ForegroundColor Cyan

# Stop containers
Write-Host "⏹️ Stopping containers..." -ForegroundColor Yellow
docker-compose down --remove-orphans

# Remove problematic images
Write-Host "🗑️ Cleaning images..." -ForegroundColor Yellow
docker rmi yarpapigateway 2>$null
docker rmi identityapi 2>$null

# Clean build cache
Write-Host "🧹 Cleaning build cache..." -ForegroundColor Yellow
docker builder prune -f

# Test API Gateway build first
Write-Host "🏗️ Testing API Gateway build..." -ForegroundColor Yellow
docker-compose build yarpapigateway

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ API Gateway built successfully!" -ForegroundColor Green
    
    # Test Identity service
    Write-Host "🏗️ Testing Identity service..." -ForegroundColor Yellow
    docker-compose build identity.api
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Identity service built successfully!" -ForegroundColor Green
        
        # Build all services
        Write-Host "🏗️ Building all services..." -ForegroundColor Yellow
        docker-compose build
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ All services built successfully!" -ForegroundColor Green
            
            # Start services
            Write-Host "🚀 Starting services..." -ForegroundColor Yellow
            docker-compose up -d
            
            Write-Host "🎉 System is starting up!" -ForegroundColor Green
            Write-Host "⏳ Waiting for services to initialize..." -ForegroundColor Cyan
            Start-Sleep 15
            
            Write-Host "`n📊 Service Status:" -ForegroundColor Cyan
            docker-compose ps
            
            Write-Host "`n🔗 Access URLs:" -ForegroundColor Cyan
            Write-Host "  Shopping Web:     http://localhost:6005" -ForegroundColor White
            Write-Host "  Identity Service: https://localhost:5001" -ForegroundColor White
            Write-Host "  API Gateway:      http://localhost:6004" -ForegroundColor White
            
            Write-Host "`n🔑 Test Users:" -ForegroundColor Cyan
            Write-Host "  Admin:    admin@eshop.com / Password123!" -ForegroundColor White
            Write-Host "  Customer: customer@eshop.com / Password123!" -ForegroundColor White
            
            Write-Host "`n✅ System is ready!" -ForegroundColor Green
            
        } else {
            Write-Host "❌ Failed to build all services" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Failed to build Identity service" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Failed to build API Gateway" -ForegroundColor Red
    Write-Host "🔍 Checking build logs..." -ForegroundColor Yellow
    docker-compose build yarpapigateway --no-cache
}

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
