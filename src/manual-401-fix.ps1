# MANUAL 401 FIX - Step by Step
Write-Host "🔧 Manual 401 Fix - Step by Step Approach" -ForegroundColor Green

Write-Host @"

📋 MANUAL STEPS TO FIX 401:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@ -ForegroundColor Cyan

$step = 1

Write-Host "$step. 🛑 Stop Shopping Web container:" -ForegroundColor Yellow
Write-Host "   docker-compose stop shopping.web" -ForegroundColor White
$confirm = Read-Host "   Execute this step? (y/n)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    docker-compose stop shopping.web
    Write-Host "   ✅ Stopped" -ForegroundColor Green
}
$step++

Write-Host "`n$step. 🗑️ Remove container and image:" -ForegroundColor Yellow
Write-Host "   docker-compose rm -f shopping.web" -ForegroundColor White
Write-Host "   docker rmi shoppingweb src-shopping.web" -ForegroundColor White
$confirm = Read-Host "   Execute this step? (y/n)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    docker-compose rm -f shopping.web
    docker rmi shoppingweb 2>$null
    docker rmi src-shopping.web 2>$null
    Write-Host "   ✅ Cleaned up" -ForegroundColor Green
}
$step++

Write-Host "`n$step. 🔍 Verify Index.cshtml.cs has the fix:" -ForegroundColor Yellow
Write-Host "   File: src/WebApps/Shopping.Web/Pages/Index.cshtml.cs" -ForegroundColor White
Write-Host "   Should contain: try/catch with ApiException handling" -ForegroundColor White
$confirm = Read-Host "   Check this file manually? (y/n)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    if (Test-Path "src/WebApps/Shopping.Web/Pages/Index.cshtml.cs") {
        $content = Get-Content "src/WebApps/Shopping.Web/Pages/Index.cshtml.cs" -Raw
        if ($content -like "*catch (ApiException ex)*" -and $content -like "*GetSampleProducts*") {
            Write-Host "   ✅ 401 fix code is present!" -ForegroundColor Green
        } else {
            Write-Host "   ❌ 401 fix code missing! Need to reapply." -ForegroundColor Red
        }
    } else {
        Write-Host "   ❌ File not found!" -ForegroundColor Red
    }
}
$step++

Write-Host "`n$step. 🏗️ Rebuild Shopping Web:" -ForegroundColor Yellow
Write-Host "   docker-compose build shopping.web --no-cache" -ForegroundColor White
$confirm = Read-Host "   Execute this step? (y/n)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    Write-Host "   Building..." -ForegroundColor Cyan
    docker-compose build shopping.web --no-cache
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Build successful!" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Build failed!" -ForegroundColor Red
        docker-compose logs shopping.web
    }
}
$step++

Write-Host "`n$step. 🚀 Start Shopping Web:" -ForegroundColor Yellow
Write-Host "   docker-compose up -d shopping.web" -ForegroundColor White
$confirm = Read-Host "   Execute this step? (y/n)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    docker-compose up -d shopping.web
    Write-Host "   ✅ Started" -ForegroundColor Green
    Write-Host "   ⏳ Waiting 15 seconds for startup..." -ForegroundColor Yellow
    Start-Sleep 15
}
$step++

Write-Host "`n$step. 🧪 Test the fix:" -ForegroundColor Yellow
Write-Host "   curl http://localhost:6005" -ForegroundColor White
$confirm = Read-Host "   Execute this test? (y/n)"
if ($confirm -eq 'y' -or $confirm -eq 'Y') {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:6005" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ HTTP 200 - NO 401 ERROR!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "   ❌ Still getting error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎯 FINAL TEST:" -ForegroundColor Cyan
$openBrowser = Read-Host "Open http://localhost:6005 in browser for final test? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
    Start-Process "http://localhost:6005"
    Write-Host "✅ Browser opened for final test!" -ForegroundColor Green
}

Write-Host @"

📝 EXPECTED RESULT:
  → No 401 Unauthorized error
  → Welcome message for anonymous users
  → "Sign In" button working
  → Sample products visible

"@ -ForegroundColor Cyan

Write-Host "`n🔧 Manual 401 fix completed!" -ForegroundColor Gray
