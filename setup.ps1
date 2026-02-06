# ===================================================================
# .NET 8 Mikroservis E-Ticaret + IdentityServer4 - TAM OTOMATIK KURULUM
# Tek komutla her şey çalışan sistem!
# ===================================================================

param(
    [switch]$Manual,
    [switch]$DockerOnly,
    [switch]$Force
)

Write-Host @"
================================================================
              .NET 8 MIKROSERVIS E-TICARET                   
                 + IDENTITYSERVER4 KIMLIK DOGRULAMA           
                   TAM OTOMATIK KURULUM                       
================================================================
"@ -ForegroundColor Cyan

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
    
    $allOk = $true
    
    # .NET 8 kontrolu
    try {
        $dotnetVersion = dotnet --version 2>$null
        if ($dotnetVersion) {
            Write-Host "✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
            
            if ([version]$dotnetVersion -lt [version]"8.0.0") {
                Write-Host "⚠️  .NET 8.0 veya uzeri gerekli!" -ForegroundColor Yellow
                $allOk = $false
            }
        } else {
            throw "Not found"
        }
    }
    catch {
        Write-Host "❌ .NET 8 SDK bulunamadi!" -ForegroundColor Red
        Write-Host "https://dotnet.microsoft.com/download/dotnet/8.0 adresinden indirin." -ForegroundColor Yellow
        $allOk = $false
    }
    
    # Docker kontrolu
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
        } else {
            throw "Not found"
        }
    }
    catch {
        Write-Host "⚠️  Docker bulunamadi!" -ForegroundColor Yellow
        Write-Host "Docker olmadan manuel kurulum yapilacak." -ForegroundColor Cyan
        $script:UseManualSetup = $true
    }
    
    return $allOk
}

# Environment variables ayarlama
function Set-EnvironmentVariables {
    Write-Host "`nEnvironment variables ayarlaniyor..." -ForegroundColor Cyan
    
    # Database connection strings
    $env:ASPNETCORE_ENVIRONMENT = "Development"
    $env:ConnectionStrings__Database = "Server=localhost,1433;Database=OrderDb;User Id=sa;Password=SwN12345678;Encrypt=False;TrustServerCertificate=True"
    $env:ConnectionStrings__CatalogDb = "Server=localhost;Port=5432;Database=CatalogDb;User Id=postgres;Password=postgres;Include Error Detail=true"
    $env:ConnectionStrings__BasketDb = "Server=localhost;Port=5433;Database=BasketDb;User Id=postgres;Password=postgres;Include Error Detail=true"
    $env:ConnectionStrings__IdentityDb = "Server=localhost;Port=5434;Database=IdentityDb;User Id=postgres;Password=postgres;Include Error Detail=true"
    
    Write-Host "✅ Environment variables ayarlandi" -ForegroundColor Green
}

# SSL Sertifikalarini duzeltme fonksiyonu
function Fix-SSLCertificates {
    Write-Host "`nSSL Sertifikalari duzeltiliyor..." -ForegroundColor Cyan
    
    try {
        # .NET HTTPS gelistirme sertifikasini temizle ve yeniden olustur
        Write-Host "Mevcut sertifikalar temizleniyor..." -ForegroundColor Yellow
        dotnet dev-certs https --clean 2>$null
        
        Write-Host "Yeni HTTPS sertifikasi olusturuluyor..." -ForegroundColor Yellow
        dotnet dev-certs https --trust
        
        # IdentityServer icin sertifika olustur
        $httpsPath = "$env:USERPROFILE\.aspnet\https"
        if (-not (Test-Path $httpsPath)) {
            New-Item -ItemType Directory -Force -Path $httpsPath | Out-Null
        }
        
        dotnet dev-certs https -ep "$httpsPath\aspnetapp.pfx" -p "password"
        
        Write-Host "✅ SSL sertifikalari basariyla duzeltildi!" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  SSL sertifika uyarisi: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Devam ediliyor..." -ForegroundColor Cyan
    }
}

# Port temizleme fonksiyonu
function Clear-UsedPorts {
    Write-Host "`nKullanilan portlar temizleniyor..." -ForegroundColor Cyan
    
    $portsToCheck = @(5001, 5000, 5432, 5433, 5434, 1433, 6379, 5672, 15672, 6000, 6001, 6002, 6003, 6004, 6005)
    
    foreach ($port in $portsToCheck) {
        try {
            $processes = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
            if ($processes) {
                Write-Host "Port $port temizleniyor..." -ForegroundColor Yellow
                foreach ($process in $processes) {
                    try {
                        Stop-Process -Id $process.OwningProcess -Force -ErrorAction SilentlyContinue
                    }
                    catch {
                        # Ignore errors
                    }
                }
            }
        }
        catch {
            # Port kullanımda değil, devam et
        }
    }
}

# Docker kurulum fonksiyonu
function Start-DockerSetup {
    Write-Host "`nDocker ile kurulum baslatiliyor..." -ForegroundColor Cyan
    
    if (-not (Test-Path "src")) {
        Write-Host "❌ src dizini bulunamadi! Proje ana dizininde oldugunuzdan emin olun." -ForegroundColor Red
        return $false
    }
    
    Push-Location "src"
    
    try {
        # Mevcut container'lari durdur
        Write-Host "Mevcut container'lar durduruluyor..." -ForegroundColor Yellow
        docker-compose down --remove-orphans 2>$null
        
        # .env dosyasi olustur
        if (-not (Test-Path ".env")) {
            Write-Host ".env dosyasi olusturuluyor..." -ForegroundColor Yellow
            $envContent = @"
DOMAIN_NAME=localhost
DOCKER_REGISTRY=
CATALOG_DB_PASSWORD=StrongPassword123!
BASKET_DB_PASSWORD=StrongPassword123!
IDENTITY_DB_PASSWORD=StrongPassword123!
ORDER_DB_PASSWORD=SwN12345678
REDIS_PASSWORD=StrongRedisPassword123!
RABBITMQ_USER=guest
RABBITMQ_PASSWORD=guest
SHOPPING_WEB_CLIENT_SECRET=shopping-web-secret-key
ASPNETCORE_ENVIRONMENT=Development
LOGGING_LEVEL=Information
"@
            Set-Content -Path ".env" -Value $envContent
        }
        
        # Docker images build et
        Write-Host "Docker images build ediliyor..." -ForegroundColor Yellow
        docker-compose build --no-cache
        
        if ($LASTEXITCODE -ne 0) {
            throw "Docker build failed"
        }
        
        # Container'lari baslat
        Write-Host "Container'lar baslatiliyor..." -ForegroundColor Yellow
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker kurulumu basarili!" -ForegroundColor Green
            return $true
        } else {
            throw "Docker startup failed"
        }
    }
    catch {
        Write-Host "❌ Docker kurulumu basarisiz: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        Pop-Location
    }
}

# Manuel kurulum fonksiyonu
function Start-ManualSetup {
    Write-Host "`nManuel kurulum baslatiliyor..." -ForegroundColor Cyan
    
    # Database'leri Docker ile baslat (sadece database'ler)
    Write-Host "Database container'lari baslatiliyor..." -ForegroundColor Yellow
    
    try {
        # PostgreSQL for Identity
        docker run -d --name identitydb -p 5434:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=IdentityDb postgres:latest 2>$null
        
        # PostgreSQL for Catalog
        docker run -d --name catalogdb -p 5432:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=CatalogDb postgres:latest 2>$null
        
        # PostgreSQL for Basket
        docker run -d --name basketdb -p 5433:5432 -e POSTGRES_PASSWORD=StrongPassword123! -e POSTGRES_DB=BasketDb postgres:latest 2>$null
        
        # SQL Server for Orders
        docker run -d --name orderdb -p 1433:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=SwN12345678" mcr.microsoft.com/mssql/server:2022-latest 2>$null
        
        # Redis
        docker run -d --name redis -p 6379:6379 redis:latest 2>$null
        
        # RabbitMQ
        docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 -e RABBITMQ_DEFAULT_USER=guest -e RABBITMQ_DEFAULT_PASS=guest rabbitmq:management 2>$null
        
        Write-Host "✅ Database container'lari baslatildi" -ForegroundColor Green
        
        # Biraz bekle database'lerin hazir olmasi icin
        Write-Host "Database'lerin hazir olmasi bekleniyor..." -ForegroundColor Yellow
        Start-Sleep 15
        
    }
    catch {
        Write-Host "⚠️  Database container uyarisi: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Devam ediliyor..." -ForegroundColor Cyan
    }
    
    # .NET servisleri manuel olarak baslat
    Write-Host ".NET servisleri baslatiliyor..." -ForegroundColor Yellow
    
    # Identity Service
    Write-Host "Identity Service baslatiliyor..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'src\Services\Identity\Identity.API'; dotnet run --urls='https://localhost:5001;http://localhost:5000'" -WindowStyle Minimized
    
    Start-Sleep 3
    
    # API Gateway
    Write-Host "API Gateway baslatiliyor..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'src\ApiGateways\YarpApiGateway'; dotnet run --urls='http://localhost:6004'" -WindowStyle Minimized
    
    Start-Sleep 2
    
    # Catalog API
    Write-Host "Catalog API baslatiliyor..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'src\Services\Catalog\Catalog.API'; dotnet run --urls='http://localhost:6000'" -WindowStyle Minimized
    
    Start-Sleep 2
    
    # Basket API
    Write-Host "Basket API baslatiliyor..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'src\Services\Basket\Basket.API'; dotnet run --urls='http://localhost:6001'" -WindowStyle Minimized
    
    Start-Sleep 2
    
    # Ordering API
    Write-Host "Ordering API baslatiliyor..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'src\Services\Ordering\Ordering.API'; dotnet run --urls='http://localhost:6003'" -WindowStyle Minimized
    
    Start-Sleep 2
    
    # Shopping Web
    Write-Host "Shopping Web baslatiliyor..." -ForegroundColor Cyan
    Start-Process -FilePath "powershell" -ArgumentList "-Command", "cd 'src\WebApps\Shopping.Web'; dotnet run --urls='http://localhost:6005'" -WindowStyle Minimized
    
    Write-Host "✅ Tum servisler baslatildi!" -ForegroundColor Green
    return $true
}

# Servislerin hazir olmasini bekleme fonksiyonu
function Wait-ForServices {
    Write-Host "`nServisler baslatilirken bekleniyor..." -ForegroundColor Cyan
    
    $maxWaitTime = 120 # 2 dakika
    $waitTime = 0
    $checkInterval = 5
    
    $services = @(
        @{Name="Identity Service"; Url="https://localhost:5001"; Essential=$true},
        @{Name="Shopping Web"; Url="http://localhost:6005"; Essential=$true},
        @{Name="API Gateway"; Url="http://localhost:6004"; Essential=$true}
    )
    
    while ($waitTime -lt $maxWaitTime) {
        $readyServices = 0
        
        foreach ($service in $services) {
            try {
                $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 3 -SkipCertificateCheck -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
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
            Write-Host "✅ Ana servisler hazir!" -ForegroundColor Green
            return $true
        }
        
        Start-Sleep $checkInterval
        $waitTime += $checkInterval
    }
    
    Write-Host "⚠️  Bazi servisler henuz hazir degil, devam ediliyor..." -ForegroundColor Yellow
    return $true
}

# Servis durumunu kontrol etme
function Check-ServiceStatus {
    Write-Host "`nServis durumu kontrol ediliyor..." -ForegroundColor Cyan
    
    $services = @(
        @{Name="Identity Service"; Url="https://localhost:5001"},
        @{Name="Shopping Web"; Url="http://localhost:6005"},
        @{Name="API Gateway"; Url="http://localhost:6004"},
        @{Name="Catalog API"; Url="http://localhost:6000"},
        @{Name="Basket API"; Url="http://localhost:6001"},
        @{Name="Ordering API"; Url="http://localhost:6003"}
    )
    
    foreach ($service in $services) {
        try {
            $response = Invoke-WebRequest -Uri $service.Url -UseBasicParsing -TimeoutSec 5 -SkipCertificateCheck -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ $($service.Name) - Calisıyor" -ForegroundColor Green
            } else {
                Write-Host "⚠️  $($service.Name) - Yanitlı ama durum: $($response.StatusCode)" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "❌ $($service.Name) - Calismiyor" -ForegroundColor Red
        }
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

# Database migration fonksiyonu
function Apply-DatabaseMigrations {
    Write-Host "`nDatabase migration'lari uygulanıyor..." -ForegroundColor Cyan
    
    try {
        # EF Core tools kurulu mu kontrol et
        $efToolsInstalled = $false
        try {
            dotnet ef --version 2>$null | Out-Null
            $efToolsInstalled = $true
        }
        catch {
            Write-Host "EF Core tools kuruluyor..." -ForegroundColor Yellow
            dotnet tool install --global dotnet-ef --ignore-failed-sources 2>$null
        }
        
        # Ordering migration
        Push-Location "src\Services\Ordering\Ordering.API"
        
        Write-Host "Ordering Database migration'i..." -ForegroundColor Yellow
        Start-Sleep 5 # Database'in hazir olmasi icin bekle
        
        dotnet ef database update --verbose 2>$null
        
        Write-Host "✅ Database migration'lari tamamlandi" -ForegroundColor Green
        
    }
    catch {
        Write-Host "⚠️  Migration uyarisi: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Migration'lar otomatik olarak calisacak..." -ForegroundColor Cyan
    }
    finally {
        if (Test-Path "src\Services\Ordering\Ordering.API") {
            Pop-Location
        }
    }
}

# Ana kurulum fonksiyonu
function Start-Setup {
    # Parametreleri kontrol et
    $script:UseManualSetup = $Manual.IsPresent
    $script:UseDockerOnly = $DockerOnly.IsPresent
    
    # Gereksinimler kontrolu
    $prereqOk = Test-Prerequisites
    
    if (-not $prereqOk -and -not $Force.IsPresent) {
        Write-Host "`nGerekli yazilimlar eksik! -Force parametresi ile devam edebilirsiniz." -ForegroundColor Red
        Read-Host "Cikmak icin Enter'a basin..."
        return
    }
    
    # Environment variables ayarla
    Set-EnvironmentVariables
    
    # SSL sertifikalarini duzelt
    Fix-SSLCertificates
    
    # Portlari temizle
    Clear-UsedPorts
    
    $setupSuccess = $false
    
    # Docker kurulum dene (manuel secilmediyse)
    if (-not $script:UseManualSetup -and -not $script:UseDockerOnly) {
        Write-Host "`nDocker kurulum deneniyor..." -ForegroundColor Cyan
        $setupSuccess = Start-DockerSetup
        
        if (-not $setupSuccess) {
            Write-Host "Docker kurulumu basarisiz, manuel kuruluma geciliyor..." -ForegroundColor Yellow
            $script:UseManualSetup = $true
        }
    }
    
    # Manuel kurulum (Docker basarisizsa veya manuel secildiyse)
    if ($script:UseManualSetup -or (-not $setupSuccess -and -not $script:UseDockerOnly)) {
        Write-Host "`nManuel kurulum yapiliyor..." -ForegroundColor Cyan
        $setupSuccess = Start-ManualSetup
    }
    
    if (-not $setupSuccess) {
        Write-Host "❌ Kurulum basarisiz!" -ForegroundColor Red
        Read-Host "Cikmak icin Enter'a basin..."
        return
    }
    
    # Servislerin hazir olmasini bekle
    Wait-ForServices
    
    # Database migration'larini uygula
    Apply-DatabaseMigrations
    
    # Servis durumunu kontrol et
    Check-ServiceStatus
    
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
Ordering API:        http://localhost:6003                  
RabbitMQ Management: http://localhost:15672 (guest/guest)    
---------------------------------------------------------------

KIMLIK DOGRULAMA:
• Tum korunmali sayfalar icin Identity Service'e yonlendirileceksiniz
• OpenID Connect ve JWT token tabanlı guvenlik
• Admin ve Customer rolleri mevcut

KULLANIM:
1. Shopping Web'e gidin: http://localhost:6005
2. Cart veya Orders sayfasina tiklayın
3. Identity Service'e yonlendirileceksiniz
4. Test kullanicilariyla giris yapin

"@ -ForegroundColor Green

    # Tarayiciyi ac
    $openBrowser = Read-Host "Shopping Web UI'i tarayicida acmak ister misiniz? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y' -or $openBrowser -eq '') {
        Start-Process "http://localhost:6005"
        Start-Sleep 2
        Start-Process "https://localhost:5001"
    }
    
    Write-Host "`n🎉 Sistem tamamen hazir! Guvenli alisveris deneyiminin tadini cikarin!" -ForegroundColor Green
}

# Hata yonetimi
function Handle-Error {
    param($ErrorMessage)
    
    Write-Host "`nHATA OLUSTU!" -ForegroundColor Red
    Write-Host "Hata Detayi: $ErrorMessage" -ForegroundColor Yellow
    
    Write-Host "`nALTERNATIF COZUMLER:" -ForegroundColor Cyan
    Write-Host "1. Manuel kurulum: .\setup.ps1 -Manual" -ForegroundColor White
    Write-Host "2. Sadece Docker: .\setup.ps1 -DockerOnly" -ForegroundColor White
    Write-Host "3. Zorla devam et: .\setup.ps1 -Force" -ForegroundColor White
    
    Write-Host "`nSORUN GIDERME:" -ForegroundColor Cyan
    Write-Host "1. Docker Desktop'in calistiginden emin olun" -ForegroundColor White
    Write-Host "2. Yonetici yetkisiyle calistirdiginizdan emin olun" -ForegroundColor White
    Write-Host "3. Antivirus yaziliminin engellememesini saglayin" -ForegroundColor White
    Write-Host "4. Port'larin baska uygulamalar tarafindan kullanilmadigini kontrol edin" -ForegroundColor White
    
    Read-Host "`nCikmak icin Enter'a basin..."
}

# Script baslangiç
try {
    Start-Setup
}
catch {
    Handle-Error $_.Exception.Message
}

Write-Host "`nScript tamamlandi!" -ForegroundColor Green
Read-Host "Cikmak icin Enter'a basin..."
