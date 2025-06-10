# Quick fix for the XML error
Write-Host "🔧 Fixing XML error and restarting build..." -ForegroundColor Cyan

# Stop containers
Write-Host "⏹️ Stopping containers..." -ForegroundColor Yellow
docker-compose down --remove-orphans

# Remove problematic images
Write-Host "🗑️ Cleaning images..." -ForegroundColor Yellow
docker rmi identityapi 2>$null
docker rmi orderingapi 2>$null

# Clean build cache
Write-Host "🧹 Cleaning build cache..." -ForegroundColor Yellow
docker builder prune -f

# Try building just Identity service first
Write-Host "🏗️ Building Identity service..." -ForegroundColor Yellow
docker-compose build identity.api

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Identity service built successfully!" -ForegroundColor Green
    
    # Build all services
    Write-Host "🏗��� Building all services..." -ForegroundColor Yellow
    docker-compose build
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All services built successfully!" -ForegroundColor Green
        
        # Start services
        Write-Host "🚀 Starting services..." -ForegroundColor Yellow
        docker-compose up -d
        
        Write-Host "🎉 System is starting up!" -ForegroundColor Green
        Write-Host "📊 Checking status in 10 seconds..." -ForegroundColor Cyan
        Start-Sleep 10
        
        docker-compose ps
        
        Write-Host "`n🔗 URLs:" -ForegroundColor Cyan
        Write-Host "  Shopping Web:     http://localhost:6005" -ForegroundColor White
        Write-Host "  Identity Service: https://localhost:5001" -ForegroundColor White
        Write-Host "  API Gateway:      http://localhost:6004" -ForegroundColor White
        
    } else {
        Write-Host "❌ Failed to build all services" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Failed to build Identity service" -ForegroundColor Red
    Write-Host "🔍 Let's check the error..." -ForegroundColor Yellow
    docker-compose build identity.api --no-cache
}

Write-Host "`nPress any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
