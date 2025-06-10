#!/bin/bash

# ToyShop Backend Services Stopper Script
# Bu script çalışan backend mikroservisleri durdurur

echo "====================================="
echo "ToyShop Backend Services Stopper"
echo "====================================="
echo ""

# Docker container'ları kontrol et
echo "🔍 Docker container'ları kontrol ediliyor..."
if command -v docker &> /dev/null && docker ps | grep -q "src_"; then
    echo "🐳 Docker container'ları bulundu."
    read -p "Docker container'ları durdurmak istiyor musunuz? (y/n): " stop_docker
    
    if [ "$stop_docker" = "y" ] || [ "$stop_docker" = "Y" ]; then
        echo "🛑 Docker servisleri durduruluyor..."
        cd src
        docker-compose down
        cd ..
        echo "✅ Docker servisleri durduruldu!"
    fi
fi

echo ""

# Manuel process'leri kontrol et
if [ -f ".backend-pids" ]; then
    echo "🔍 Manuel başlatılmış servisler bulundu."
    read -p "Manuel servisleri durdurmak istiyor musunuz? (y/n): " stop_manual
    
    if [ "$stop_manual" = "y" ] || [ "$stop_manual" = "Y" ]; then
        echo "🛑 Manuel servisler durduruluyor..."
        
        # PID dosyasını oku
        source .backend-pids
        
        # Her PID'i kontrol et ve durdur
        if [ ! -z "$CATALOG_PID" ] && kill -0 $CATALOG_PID 2>/dev/null; then
            echo "📦 Catalog Service durduruluyor (PID: $CATALOG_PID)..."
            kill $CATALOG_PID
        fi
        
        if [ ! -z "$BASKET_PID" ] && kill -0 $BASKET_PID 2>/dev/null; then
            echo "🛒 Basket Service durduruluyor (PID: $BASKET_PID)..."
            kill $BASKET_PID
        fi
        
        if [ ! -z "$DISCOUNT_PID" ] && kill -0 $DISCOUNT_PID 2>/dev/null; then
            echo "💰 Discount Service durduruluyor (PID: $DISCOUNT_PID)..."
            kill $DISCOUNT_PID
        fi
        
        if [ ! -z "$ORDERING_PID" ] && kill -0 $ORDERING_PID 2>/dev/null; then
            echo "📋 Ordering Service durduruluyor (PID: $ORDERING_PID)..."
            kill $ORDERING_PID
        fi
        
        if [ ! -z "$GATEWAY_PID" ] && kill -0 $GATEWAY_PID 2>/dev/null; then
            echo "🌐 API Gateway durduruluyor (PID: $GATEWAY_PID)..."
            kill $GATEWAY_PID
        fi
        
        if [ ! -z "$WEB_PID" ] && kill -0 $WEB_PID 2>/dev/null; then
            echo "🛍️ Shopping Web durduruluyor (PID: $WEB_PID)..."
            kill $WEB_PID
        fi
        
        # PID dosyasını sil
        rm -f .backend-pids
        
        echo "✅ Manuel servisler durduruldu!"
    fi
else
    echo "ℹ️  Manuel başlatılmış servis bulunamadı."
fi

echo ""

# Port'larda çalışan .NET process'lerini kontrol et
echo "🔍 Port'larda çalışan .NET process'leri kontrol ediliyor..."
dotnet_processes=$(ps aux | grep "dotnet.*run" | grep -v grep | wc -l)

if [ $dotnet_processes -gt 0 ]; then
    echo "⚠️  Hala çalışan $dotnet_processes .NET process'i bulundu."
    read -p "Tüm .NET process'lerini zorla durdurmak istiyor musunuz? (y/n): " force_kill
    
    if [ "$force_kill" = "y" ] || [ "$force_kill" = "Y" ]; then
        echo "🛑 Tüm .NET process'leri durduruluyor..."
        pkill -f "dotnet.*run"
        echo "✅ Tüm .NET process'leri durduruldu!"
    fi
fi

echo ""

# Port kullanımını kontrol et
echo "🔍 Port kullanımı kontrol ediliyor..."
for port in 6000 6001 6002 6003 6004 6005; do
    if lsof -ti:$port &>/dev/null; then
        echo "⚠️  Port $port hala kullanılıyor."
        pid=$(lsof -ti:$port)
        echo "   Process PID: $pid"
        
        read -p "Bu process'i durdurmak istiyor musunuz? (y/n): " kill_port_process
        if [ "$kill_port_process" = "y" ] || [ "$kill_port_process" = "Y" ]; then
            kill $pid
            echo "✅ Port $port'daki process durduruldu."
        fi
    fi
done

echo ""
echo "🔍 Frontend durumunu kontrol etmek için:"
echo "http://localhost:3000/api/health"
echo ""
echo "✅ İşlem tamamlandı!"

read -p "Çıkmak için Enter'a basın"
