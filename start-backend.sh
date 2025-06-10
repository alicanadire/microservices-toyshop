#!/bin/bash

# ToyShop Backend Services Starter Script
# Bu script backend mikroservisleri sırayla başlatır

echo "====================================="
echo "ToyShop Backend Services Starter"
echo "====================================="
echo ""

# .NET SDK kontrolü
echo "🔍 .NET SDK kontrol ediliyor..."
if command -v dotnet &> /dev/null; then
    dotnet_version=$(dotnet --version)
    echo "✅ .NET SDK bulundu: $dotnet_version"
else
    echo "❌ .NET SDK bulunamadı! Lütfen .NET 8 SDK'yı yükleyin."
    echo "İndirme linki: https://dotnet.microsoft.com/download"
    read -p "Devam etmek için Enter'a basın"
    exit 1
fi

echo ""

# Docker kontrolü
echo "🔍 Docker kontrol ediliyor..."
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "✅ Docker bulundu: $docker_version"
    read -p "Docker kullanarak tüm servisleri başlatmak istiyor musunuz? (y/n) [Önerilen]: " use_docker
else
    echo "⚠️  Docker bulunamadı, manuel başlatma yapılacak."
    use_docker="n"
fi

echo ""

if [ "$use_docker" = "y" ] || [ "$use_docker" = "Y" ]; then
    # Docker ile başlatma
    echo "🐳 Docker Compose ile backend servisleri başlatılıyor..."
    cd src
    
    # Eski container'ları temizle
    echo "🧹 Eski container'lar temizleniyor..."
    docker-compose down 2>/dev/null
    
    # Servisleri başlat
    echo "🚀 Backend servisleri başlatılıyor..."
    if docker-compose up -d; then
        echo ""
        echo "✅ Docker servisleri başlatıldı!"
        echo ""
        echo "📋 Servis URL'leri:"
        echo "- Shopping Web: https://localhost:6065"
        echo "- API Gateway: https://localhost:6064"
        echo "- Catalog API: http://localhost:6000"
        echo "- Basket API: http://localhost:6001"
        echo "- Ordering API: http://localhost:6003"
        echo ""
        echo "🔍 Container durumunu kontrol etmek için: docker ps"
    else
        echo "❌ Docker başlatma hatası!"
        echo "Manuel başlatma yapılacak..."
        use_docker="n"
    fi
    
    cd ..
fi

if [ "$use_docker" != "y" ] && [ "$use_docker" != "Y" ]; then
    # Manuel başlatma
    echo "🛠️  Manuel başlatma seçildi..."
    echo ""
    echo "Bu işlem birden fazla terminal process'i başlatacak."
    read -p "Devam etmek istiyor musunuz? (y/n): " continue_manual
    
    if [ "$continue_manual" = "y" ] || [ "$continue_manual" = "Y" ]; then
        echo ""
        echo "🚀 Mikroservisler başlatılıyor..."
        
        # Background process'ler için log dosyaları
        mkdir -p logs
        
        # Catalog Service
        echo "📦 Catalog Service başlatılıyor..."
        (cd src/Services/Catalog/Catalog.API && dotnet run > ../../../logs/catalog.log 2>&1) &
        CATALOG_PID=$!
        sleep 2
        
        # Basket Service
        echo "🛒 Basket Service başlatılıyor..."
        (cd src/Services/Basket/Basket.API && dotnet run > ../../../logs/basket.log 2>&1) &
        BASKET_PID=$!
        sleep 2
        
        # Discount Service
        echo "💰 Discount Service başlatılıyor..."
        (cd src/Services/Discount/Discount.Grpc && dotnet run > ../../../logs/discount.log 2>&1) &
        DISCOUNT_PID=$!
        sleep 2
        
        # Ordering Service
        echo "📋 Ordering Service başlatılıyor..."
        (cd src/Services/Ordering/Ordering.API && dotnet run > ../../../logs/ordering.log 2>&1) &
        ORDERING_PID=$!
        sleep 2
        
        # API Gateway
        echo "🌐 API Gateway başlatılıyor..."
        (cd src/ApiGateways/YarpApiGateway && dotnet run > ../../logs/gateway.log 2>&1) &
        GATEWAY_PID=$!
        sleep 2
        
        # Shopping Web (isteğe bağlı)
        read -p "Shopping.Web uygulamasını da başlatmak istiyor musunuz? (y/n): " start_web
        if [ "$start_web" = "y" ] || [ "$start_web" = "Y" ]; then
            echo "🛍️  Shopping Web başlatılıyor..."
            (cd src/WebApps/Shopping.Web && dotnet run > ../../logs/shopping-web.log 2>&1) &
            WEB_PID=$!
        fi
        
        # PID'leri kaydet
        echo "# ToyShop Backend Process IDs" > .backend-pids
        echo "CATALOG_PID=$CATALOG_PID" >> .backend-pids
        echo "BASKET_PID=$BASKET_PID" >> .backend-pids
        echo "DISCOUNT_PID=$DISCOUNT_PID" >> .backend-pids
        echo "ORDERING_PID=$ORDERING_PID" >> .backend-pids
        echo "GATEWAY_PID=$GATEWAY_PID" >> .backend-pids
        if [ "$start_web" = "y" ] || [ "$start_web" = "Y" ]; then
            echo "WEB_PID=$WEB_PID" >> .backend-pids
        fi
        
        echo ""
        echo "✅ Tüm servisler başlatıldı!"
        echo "⏱️  Servislerin tam olarak hazır olması 30-60 saniye sürebilir."
        echo ""
        echo "📋 Servis URL'leri:"
        echo "- API Gateway: https://localhost:6004"
        echo "- Catalog API: http://localhost:6000"
        echo "- Basket API: http://localhost:6001"
        echo "- Discount gRPC: http://localhost:6002"
        echo "- Ordering API: http://localhost:6003"
        if [ "$start_web" = "y" ] || [ "$start_web" = "Y" ]; then
            echo "- Shopping Web: https://localhost:6005"
        fi
        echo ""
        echo "📝 Log dosyaları: logs/ klasöründe"
        echo "🛑 Servisleri durdurmak için: ./stop-backend.sh"
    else
        echo "❌ İşlem iptal edildi."
    fi
fi

echo ""
echo "🔍 Frontend durumunu kontrol etmek için:"
echo "http://localhost:3000/api/health"
echo ""
echo "📖 Daha fazla bilgi için: API_SORUN_COZUM_KILAVUZU.md"
echo ""

read -p "Çıkmak için Enter'a basın"
