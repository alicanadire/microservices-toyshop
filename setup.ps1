# ===================================================================
# .NET 8 Mikroservis E-Ticaret Projesi - Otomatik Kurulum Scripti
# IdentityServer4 ile Güvenli Kimlik Doğrulama Sistemi
# PowerShell ile SSL, Migration ve Docker kurulumu
# ===================================================================

Write-Host "=== .NET 8 Mikroservis E-Ticaret + IdentityServer4 Kurulum Basliyor ===" -ForegroundColor Green

# Admin yetkisi kontrolu
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "Bu script yonetici (Administrator) yetkisiyle calistirilmalidir!" -ForegroundColor Red
    Write-Host "PowerShell'i 'Yonetici olarak calistir' secenegiyle acin." -ForegroundColor Yellow
    Read-Host "Devam etmek icin Enter'a basin..."
    exit 1
}

# Gerekli yazilimlari kontrol etme fonksiyonu
function Test-Prerequisites {
    Write-Host "`nGerekli yazilimlar kontrol ediliyor..." -ForegroundColor Cyan
    
    # .NET 8 kontrolu
    try {
        $dotnetVersion = dotnet --version
        Write-Host ".NET SDK: $dotnetVersion" -ForegroundColor Green
        
        if ([version]$dotnetVersion -lt [version]"8.0.0") {
            throw ".NET 8.0 veya uzeri gerekli!"
        }
    }
    catch {
        Write-Host ".NET 8 SDK bulunamadi!" -ForegroundColor Red
        Write-Host "https://dotnet.microsoft.com/download/dotnet/8.0 adresinden indirin." -ForegroundColor Yellow
        return $false
    }
    
    # Docker kontrolu
    try {
        $dockerVersion = docker --version
        Write-Host "Docker: $dockerVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "Docker bulunamadi!" -ForegroundColor Red
        Write-Host "https://www.docker.com/products/docker-desktop adresinden indirin." -ForegroundColor Yellow
        return $false
    }
    
    # Docker Compose kontrolu
    try {
        $dockerComposeVersion = docker-compose --version
        Write-Host "Docker Compose: $dockerComposeVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "Docker Compose bulunamadi!" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# SSL Sertifikalarini duzeltme fonksiyonu
function Fix-SSLCertificates {
    Write-Host "`nSSL Sertifikalari duzeltiliyor..." -ForegroundColor Cyan
    
    try {
        # .NET HTTPS gelistirme sertifikasini temizle ve yeniden olustur
        Write-Host "Mevcut sertifikalar temizleniyor..." -ForegroundColor Yellow
        dotnet dev-certs https --clean
        
        Write-Host "Yeni HTTPS sertifikasi olusturuluyor..." -ForegroundColor Yellow
        dotnet dev-certs https --trust
        
        # IdentityServer icin sertifika olustur
        if (-not (Test-Path "$env:USERPROFILE\.aspnet\https")) {
            New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.aspnet\https"
        }
        
        dotnet dev-certs https -ep "$env:USERPROFILE\.aspnet\https\aspnetapp.pfx" -p "password"
        
        Write-Host "SSL sertifikalari basariyla duzeltildi!" -ForegroundColor Green
        Write-Host "IdentityServer sertifikasi: $env:USERPROFILE\.aspnet\https\aspnetapp.pfx" -ForegroundColor Cyan
    }
    catch {
        Write-Host "SSL sertifika olusturma hatasi: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Manuel olarak 'dotnet dev-certs https --trust' calistirin." -ForegroundColor Yellow
    }
}

# Environment dosyasi hazirlama fonksiyonu
function Prepare-Environment {
    Write-Host "`nEnvironment dosyasi hazirlaniyor..." -ForegroundColor Cyan
    
    $envPath = "src\.env"
    
    if (-not (Test-Path $envPath)) {
        Write-Host ".env dosyasi bulunamadi, .env.template'den olusturuluyor..." -ForegroundColor Yellow
        
        if (Test-Path "src\.env.template") {
            Copy-Item "src\.env.template" $envPath
            Write-Host ".env dosyasi basariyla olusturuldu!" -ForegroundColor Green
        } else {
            # Varsayılan .env dosyasi olustur
            $defaultEnv = @"
# EShop Mikroservices Environment Variables
DOMAIN_NAME=localhost
DOCKER_REGISTRY=

# Database Passwords
CATALOG_DB_PASSWORD=StrongPassword123!
BASKET_DB_PASSWORD=StrongPassword123!
IDENTITY_DB_PASSWORD=StrongPassword123!
ORDER_DB_PASSWORD=StrongPassword123!

# Redis Configuration
REDIS_PASSWORD=StrongRedisPassword123!

# RabbitMQ Configuration
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=StrongRabbitPassword123!

# Identity Server Configuration
SHOPPING_WEB_CLIENT_SECRET=shopping-web-secret-key

# Environment
ASPNETCORE_ENVIRONMENT=Development
LOGGING_LEVEL=Information
"@
            Set-Content -Path $envPath -Value $defaultEnv
            Write-Host "Varsayilan .env dosyasi olusturuldu!" -ForegroundColor Green
        }
    } else {
        Write-Host ".env dosyasi mevcut, kullaniliyor..." -ForegroundColor Green
    }
}

# Docker servislerini durdurma fonksiyonu
function Stop-ExistingServices {
    Write-Host "`nMevcut Docker servisleri durduruluyor..." -ForegroundColor Cyan
    
    # Mevcut container'lari durdur ve temizle
    docker-compose -f src/docker-compose.yml -f src/docker-compose.override.yml down --remove-orphans 2>$null
    
    # Kullanilan portlari temizle
    $portsToCheck = @(5001, 5000, 5432, 5433, 5434, 1433, 6379, 5672, 15672, 6000, 6001, 6002, 6003, 6004, 6005)
    
    foreach ($port in $portsToCheck) {
        try {
            $process = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Port $port kullanimda, temizleniyor..." -ForegroundColor Yellow
                Stop-Process -Id $process.OwningProcess -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            # Port kullanımda değil, devam et
        }
    }
}

# Database Migration fonksiyonu
function Run-DatabaseMigrations {
    Write-Host "`nVeritabani migration'lari hazirlaniyor..." -ForegroundColor Cyan
    
    # EF Core tools kurulu mu kontrol et
    try {
        dotnet tool install --global dotnet-ef --ignore-failed-sources 2>$null
        Write-Host "Entity Framework tools hazir." -ForegroundColor Green
    }
    catch {
        Write-Host "EF Core tools kurulumunda uyari (zaten kurulu olabilir)." -ForegroundColor Yellow
    }
    
    # Ordering Service migration'i
    Push-Location "src/Services/Ordering/Ordering.API"
    try {
        Write-Host "Ordering Service migration dosyalari kontrol ediliyor..." -ForegroundColor Yellow
        
        if (-not (Test-Path "Migrations")) {
            Write-Host "Migration klasoru bulunamadi, migration'lar container icinde uygulanacak..." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Migration hazirliginda hata: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
}

# Docker servisleri baslatma fonksiyonu
function Start-DockerServices {
    Write-Host "`nDocker servisleri baslatiliyor..." -ForegroundColor Cyan
    
    # src dizinine gec
    if (-not (Test-Path "src")) {
        Write-Host "src dizini bulunamadi! Proje ana dizininde oldugunuzdan emin olun." -ForegroundColor Red
        return $false
    }
    
    Push-Location "src"
    
    try {
        # Docker images build et
        Write-Host "Docker images build ediliyor..." -ForegroundColor Yellow
        docker-compose -f docker-compose.yml -f docker-compose.override.yml build --no-cache
        
        # Docker compose ile servisleri baslat
        Write-Host "Docker Compose baslatiliyor..." -ForegroundColor Yellow
        docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker servisleri basariyla baslatildi!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Docker servisleri baslatilamadi!" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Docker Compose hatasi: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        Pop-Location
    }
}

# Servislerin hazir olmasini bekleme fonksiyonu
function Wait-ForServices {
    Write-Host "`nServisler baslatilirken bekleniyor..." -ForegroundColor Cyan
    
    $maxWaitTime = 300 # 5 dakika
    $waitTime = 0
    $checkInterval = 10
    
    $services = @(
        @{Name="Identity Service"; Port=5001},
        @{Name="PostgreSQL Catalog"; Port=5432},
        @{Name="PostgreSQL Basket"; Port=5433},
        @{Name="PostgreSQL Identity"; Port=5434},
        @{Name="SQL Server"; Port=1433},
        @{Name="Redis"; Port=6379},
        @{Name="RabbitMQ"; Port=5672},
        @{Name="Catalog API"; Port=6000},
        @{Name="Basket API"; Port=6001},
        @{Name="Discount gRPC"; Port=6002},
        @{Name="Ordering API"; Port=6003},
        @{Name="YARP Gateway"; Port=6004},
        @{Name="Shopping Web"; Port=6005}
    )
    
    Write-Host "Kontrol edilen servisler:" -ForegroundColor Cyan
    foreach ($service in $services) {
        Write-Host "  - $($service.Name) (Port: $($service.Port))" -ForegroundColor White
    }
    
    while ($waitTime -lt $maxWaitTime) {
        $readyServices = 0
        
        foreach ($service in $services) {
            try {
                $connection = Test-NetConnection -ComputerName localhost -Port $service.Port -WarningAction SilentlyContinue -InformationLevel Quiet
                if ($connection.TcpTestSucceeded) {
                    $readyServices++
                }
            }
            catch {
                # Service henuz hazir degil
            }
        }
        
        $progress = [math]::Round(($readyServices / $services.Count) * 100, 1)
        Write-Host "Servis durumu: $readyServices/$($services.Count) hazir (%$progress) - $waitTime/$maxWaitTime saniye" -ForegroundColor Yellow
        
        if ($readyServices -eq $services.Count) {
            Write-Host "Tum servisler hazir!" -ForegroundColor Green
            return $true
        }
        
        Start-Sleep $checkInterval
        $waitTime += $checkInterval
    }
    
    Write-Host "Bazi servisler belirtilen surede baslatilamadi, devam ediliyor..." -ForegroundColor Yellow
    return $true
}

# Migration'lari uygulama fonksiyonu
function Apply-DatabaseMigrations {
    Write-Host "`nVeritabani migration'lari uygulanıyor..." -ForegroundColor Cyan
    
    # Biraz daha bekle database'lerin tamamen hazir olmasi icin
    Write-Host "Database'lerin tamamen hazir olmasi icin bekleniyor..." -ForegroundColor Yellow
    Start-Sleep 45
    
    Push-Location "src/Services/Ordering/Ordering.API"
    try {
        # Entity Framework migration'ini uygula
        Write-Host "Ordering Database migration'i uygulaniyor..." -ForegroundColor Yellow
        
        # Connection string'i test et
        $connectionString = "Server=localhost,1433;Database=OrderDb;User Id=sa;Password=SwN12345678;Encrypt=False;TrustServerCertificate=True"
        
        # Migration'i uygula
        $env:ConnectionStrings__Database = $connectionString
        dotnet ef database update --verbose
        
        Write-Host "Ordering Database migration'i basariyla uygulandi!" -ForegroundColor Green
    }
    catch {
        Write-Host "Ordering Migration hatasi: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Migration container icinde otomatik olarak calisacak..." -ForegroundColor Yellow
    }
    finally {
        Pop-Location
    }
}

# Container durumunu kontrol etme fonksiyonu
function Check-ContainerStatus {
    Write-Host "`nContainer durumlari kontrol ediliyor..." -ForegroundColor Cyan
    
    try {
        $containers = docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        Write-Host $containers -ForegroundColor White
    }
    catch {
        Write-Host "Container listesi alinamadi." -ForegroundColor Red
    }
    
    # Health check'leri kontrol et
    $healthUrls = @(
        @{Name="Identity Service"; Url="https://localhost:5001"},
        @{Name="Catalog API"; Url="http://localhost:6000/health"},
        @{Name="Basket API"; Url="http://localhost:6001/health"}, 
        @{Name="Ordering API"; Url="http://localhost:6003/health"},
        @{Name="API Gateway"; Url="http://localhost:6004/health"},
        @{Name="Shopping Web"; Url="http://localhost:6005"}
    )
    
    Write-Host "`nServis Health Check'leri..." -ForegroundColor Cyan
    foreach ($healthUrl in $healthUrls) {
        try {
            $response = Invoke-WebRequest -Uri $healthUrl.Url -UseBasicParsing -TimeoutSec 10 -SkipCertificateCheck
            if ($response.StatusCode -eq 200) {
                Write-Host "$($healthUrl.Name) - Healthy" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "$($healthUrl.Name) - Initializing..." -ForegroundColor Yellow
        }
    }
}

# Log'lari gosterme fonksiyonu
function Show-ServiceLogs {
    Write-Host "`nSon 30 log satiri gosteriliyor..." -ForegroundColor Cyan
    
    Push-Location "src"
    try {
        docker-compose logs --tail=30
    }
    finally {
        Pop-Location
    }
}

# Test kullanicilari bilgisi
function Show-TestCredentials {
    Write-Host @"

==============================================================
                      TEST KULLANICILARI                    
==============================================================

ADMIN KULLANICI:
  Email:    admin@eshop.com
  Sifre:    Password123!
  Roller:   Admin

MUSTERI KULLANICI:
  Email:    customer@eshop.com  
  Sifre:    Password123!
  Roller:   Customer

VERITABANI ERISIM:
  RabbitMQ: http://localhost:15672 (guest/guest)
  
==============================================================
"@ -ForegroundColor Yellow
}

# Ana kurulum fonksiyonu
function Start-Setup {
    # Header
    Write-Host @"
================================================================
              .NET 8 MIKROSERVIS E-TICARET                   
                 + IDENTITYSERVER4 KIMLIK DOGRULAMA           
                   OTOMATIK KURULUM                           
================================================================
"@ -ForegroundColor Cyan

    # Gereksinimler kontrolu
    if (-not (Test-Prerequisites)) {
        Write-Host "`nGerekli yazilimlar eksik! Kurulumu tamamlayip tekrar deneyin." -ForegroundColor Red
        Read-Host "Cikmak icin Enter'a basin..."
        return
    }
    
    # Environment dosyasini hazirla
    Prepare-Environment
    
    # SSL sertifikalarini duzelt
    Fix-SSLCertificates
    
    # Mevcut servisleri durdur
    Stop-ExistingServices
    
    # Migration hazirligi
    Run-DatabaseMigrations
    
    # Docker servislerini baslat
    if (-not (Start-DockerServices)) {
        Write-Host "`nDocker servisleri baslatilamadi!" -ForegroundColor Red
        Read-Host "Cikmak icin Enter'a basin..."
        return
    }
    
    # Servislerin hazir olmasini bekle
    Wait-ForServices
    
    # Migration'lari uygula
    Apply-DatabaseMigrations
    
    # Container durumlarini kontrol et
    Check-ContainerStatus
    
    # Test kullanicilari bilgisini goster
    Show-TestCredentials
    
    # Basari mesaji
    Write-Host @"

=============================================================== 
                     KURULUM TAMAMLANDI!                     
                  IDENTITYSERVER4 ENTEGRASYONU                
===============================================================

UYGULAMALARA ERISIM:
---------------------------------------------------------------
Shopping Web UI:     http://localhost:6005                  
Identity Service:    https://localhost:5001                 
API Gateway:         http://localhost:6004                  
Catalog API:         http://localhost:6000                  
Basket API:          http://localhost:6001                  
Discount gRPC:       http://localhost:6002                  
Ordering API:        http://localhost:6003                  
RabbitMQ Management: http://localhost:15672 (guest/guest)    
---------------------------------------------------------------

KIMLIK DOGRULAMA:
• Tum korunmali sayfalar icin Identity Service'e yonlendirileceksiniz
• OpenID Connect ve JWT token tabانli guvenlik
• Admin ve Customer rolleri mevcut

YONETIM KOMUTLARI:
• Container'lari durdur:  docker-compose -f src/docker-compose.yml down
• Log'lari gor:           docker-compose -f src/docker-compose.yml logs
• Yeniden baslat:         docker-compose -f src/docker-compose.yml restart

"@ -ForegroundColor Green

    # Tarayiciyi ac
    $openBrowser = Read-Host "Shopping Web UI'i tarayicida acmak ister misiniz? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
        Start-Process "http://localhost:6005"
        Start-Sleep 2
        Start-Process "https://localhost:5001"
    }
    
    # Log'lari goster secenegi
    $showLogs = Read-Host "`nSon log'lari gormek ister misiniz? (y/n)"
    if ($showLogs -eq 'y' -or $showLogs -eq 'Y') {
        Show-ServiceLogs
    }
}

# Hata yonetimi
function Handle-Error {
    param($ErrorMessage)
    
    Write-Host "`nHATA OLUSTU!" -ForegroundColor Red
    Write-Host "Hata Detayi: $ErrorMessage" -ForegroundColor Yellow
    
    Write-Host "`nSORUN GIDERME:" -ForegroundColor Cyan
    Write-Host "1. Docker Desktop'in calistiginden emin olun" -ForegroundColor White
    Write-Host "2. Yonetici yetkisiyle calistirdiginizdan emin olun" -ForegroundColor White
    Write-Host "3. Antivirus yaziliminin Docker'i engellememesini saglayin" -ForegroundColor White
    Write-Host "4. Port'larin baska uygulamalar tarafindan kullanilmadigini kontrol edin" -ForegroundColor White
    Write-Host "5. SSL sertifikalarinin dogru kuruldugundan emin olun" -ForegroundColor White
    Write-Host "6. Identity Service'in HTTPS sertifikasini manuel olarak kabul edin" -ForegroundColor White
    
    Write-Host "`nMANUEL BASLATMA:" -ForegroundColor Cyan
    Write-Host "cd src" -ForegroundColor White
    Write-Host "docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d" -ForegroundColor White
    
    Show-ServiceLogs
    
    Read-Host "`nCikmak icin Enter'a basin..."
}

# Script baslangiç
try {
    Start-Setup
}
catch {
    Handle-Error $_.Exception.Message
}

Write-Host "`nScript tamamlandi. Guvenli alisveris deneyimi icin hazir!" -ForegroundColor Green
Read-Host "Cikmak icin Enter'a basin..."
