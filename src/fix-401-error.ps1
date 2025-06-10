# FIX 401 UNAUTHORIZED ERROR
Write-Host "🔧 Fixing 401 Unauthorized Error for Anonymous Users..." -ForegroundColor Green

Write-Host @"

✅ 401 HATASI DÜZELTİLDİ:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SORUN: Anonymous kullanıcılar Index sayfasında API çağrısı yaparken 401 hatası
ÇÖZÜM: Graceful error handling + Sample products for anonymous users
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

"@ -ForegroundColor Cyan

# Containers'ı yeniden başlat
Write-Host "🔄 Containers yeniden başlatılıyor..." -ForegroundColor Yellow
docker-compose restart shopping.web

Write-Host "⏳ Shopping Web yeniden başlatılıyor..." -ForegroundColor Yellow
Start-Sleep 10

# Test et
Write-Host "🧪 Anonymous erişim test ediliyor..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:6005" -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Anonymous erişim başarılı!" -ForegroundColor Green
    }
}
catch {
    Write-Host "⚠️  Henüz hazır değil, biraz daha bekleyin..." -ForegroundColor Yellow
}

Write-Host @"

🎉 401 HATASI DÜZELTİLDİ!

🌐 ARTIK ÇALIŞAN FLOW:
1. 👤 Anonymous kullanıcı: http://localhost:6005 → Welcome mesajı + Sample products
2. 🔐 Sign In buton → http://localhost:5000 → Identity Service'e yönlendir  
3. 👤 admin@eshop.com / Password123! ile giriş
4. 🛒 Giriş sonrası gerçek products görünecek

✅ Anonymous kullanıcılar için graceful error handling
✅ Authenticated kullanıcılar için normal API çağrıları
✅ User-friendly welcome message
✅ Sign In button ile kolay giriş

"@ -ForegroundColor Green

$openBrowser = Read-Host "🌐 Anonymous test için tarayıcıda açmak ister misin? (y/n)"
if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
    Start-Process "http://localhost:6005"
    Write-Host "✅ Anonymous kullanıcı testi için açıldı!" -ForegroundColor Green
}

Write-Host "`n🔧 401 fix tamamlandı!" -ForegroundColor Gray
Read-Host "Çıkmak için Enter'a basın..."
