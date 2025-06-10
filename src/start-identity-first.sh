#!/bin/bash

echo "🔑 EShop Identity Server First Startup"
echo "===================================="
echo "🎯 Identity Server MUTLAKA çalışacak!"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker bulunamadı. Docker Desktop'ı kurun."
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker çalışmıyor. Docker Desktop'ı başlatın."
    exit 1
fi

echo "✅ Docker çalışıyor"

# Use fixed compose file
COMPOSE_FILE="docker-compose.fixed.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ $COMPOSE_FILE bulunamadı. Doğru dizinde olduğunuzdan emin olun."
    exit 1
fi

echo "🧹 Mevcut container'ları temizliyorum..."
docker-compose -f $COMPOSE_FILE down --remove-orphans 2>/dev/null
docker system prune -f 2>/dev/null

echo "🏗️  Infrastructure servislerini başlatıyorum..."
docker-compose -f $COMPOSE_FILE up -d identitydb catalogdb basketdb orderdb distributedcache messagebroker

echo "⏳ Veritabanlarının hazır olmasını bekliyorum..."
sleep 20

echo "🔑 Identity Server'ı build ediyorum (ÖNCELIK)..."
docker-compose -f $COMPOSE_FILE build identity.api --no-cache

echo "🚀 Identity Server'ı başlatıyorum..."
docker-compose -f $COMPOSE_FILE up -d identity.api

echo "⏳ Identity Server'ın hazır olmasını bekliyorum..."
for i in {1..30}; do
    if curl -s http://localhost:5000/health > /dev/null 2>&1; then
        echo "✅ Identity Server hazır!"
        break
    fi
    echo "  Deneme $i/30 - Identity Server henüz hazır değil..."
    sleep 3
done

echo "🏗️  Diğer servisleri build ediyorum..."
docker-compose -f $COMPOSE_FILE build catalog.api basket.api discount.grpc ordering.api yarpapigateway shopping.web --no-cache

echo "🚀 Tüm servisleri başlatıyorum..."
docker-compose -f $COMPOSE_FILE up -d

echo "⏳ Servislerin hazır olmasını bekliyorum..."
sleep 30

echo ""
echo "📊 Container Durumu:"
docker-compose -f $COMPOSE_FILE ps

echo ""
echo "🎉 EShop Microservices Başlatıldı!"
echo "=================================="
echo ""
echo "🔑 Identity Server: http://localhost:5000"
echo "🛒 Shopping Web:    http://localhost:6005"
echo "🚪 API Gateway:     http://localhost:6004"
echo ""
echo "👤 Test Kullanıcıları:"
echo "  📧 admin@eshop.com / Password123!"
echo "  📧 customer@eshop.com / Password123!"
echo ""
echo "🎯 Şimdi http://localhost:6005 adresine gidip Sign In yapabilirsiniz!"
echo ""
