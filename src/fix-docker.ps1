# PowerShell script to fix Docker build issues
# Run this from the src directory

Write-Host "🔧 Docker Build Fix Script" -ForegroundColor Cyan

# Check if we're in the src directory
if (-not (Test-Path "docker-compose.yml")) {
    Write-Host "❌ Please run this script from the src directory!" -ForegroundColor Red
    exit 1
}

Write-Host "⏹️ Stopping existing containers..." -ForegroundColor Yellow
docker-compose down --remove-orphans 2>$null

Write-Host "🗑️ Cleaning up Docker images..." -ForegroundColor Yellow
docker rmi identityapi 2>$null
docker builder prune -f

Write-Host "🏗️ Building Identity Service first..." -ForegroundColor Yellow
docker-compose build identity.api

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Identity Service built successfully!" -ForegroundColor Green
    
    Write-Host "🏗️ Building all services..." -ForegroundColor Yellow
    docker-compose build --no-cache
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All services built successfully!" -ForegroundColor Green
        
        Write-Host "🚀 Starting services..." -ForegroundColor Yellow
        docker-compose up -d
        
        Write-Host "🎉 Setup complete! Services starting..." -ForegroundColor Green
        Start-Sleep 5
        
        Write-Host "`n📊 Service Status:" -ForegroundColor Cyan
        docker-compose ps
        
        Write-Host "`n🔗 Access URLs:" -ForegroundColor Cyan
        Write-Host "  Identity Service: https://localhost:5001" -ForegroundColor White
        Write-Host "  Shopping Web:     http://localhost:6005" -ForegroundColor White
        Write-Host "  API Gateway:      http://localhost:6004" -ForegroundColor White
        
        Write-Host "`n🔑 Test Users:" -ForegroundColor Cyan
        Write-Host "  Admin:    admin@eshop.com / Password123!" -ForegroundColor White
        Write-Host "  Customer: customer@eshop.com / Password123!" -ForegroundColor White
        
    } else {
        Write-Host "❌ Failed to build all services" -ForegroundColor Red
        Write-Host "See BUILD_INSTRUCTIONS.md for manual setup" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Failed to build Identity Service" -ForegroundColor Red
    Write-Host "`n🔍 Troubleshooting:" -ForegroundColor Cyan
    Write-Host "1. Make sure you're in the src directory" -ForegroundColor White
    Write-Host "2. Check if Docker Desktop is running" -ForegroundColor White
    Write-Host "3. Try running as Administrator" -ForegroundColor White
    Write-Host "4. See BUILD_INSTRUCTIONS.md for manual setup" -ForegroundColor White
}

Read-Host "`nPress Enter to continue..."
