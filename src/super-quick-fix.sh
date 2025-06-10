#!/bin/bash

echo "⚡ SUPER QUICK IDENTITY FIX"
echo "========================="

# Complete cleanup
echo "🧹 Tam temizlik..."
docker-compose down --remove-orphans
docker system prune -f

# Remove old identity image
echo "🗑️  Eski Identity image'ını siliyor..."
docker rmi $(docker images | grep identityapi | awk '{print $3}') 2>/dev/null || true

# Build identity with no cache and verbose output
echo "🔨 Identity Server build (verbose)..."
docker-compose build identity.api --no-cache --progress=plain

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build başarılı! Başlatılıyor..."
    
    # Start Identity directly (no database dependency for in-memory)
    docker-compose up -d identity.api
    
    echo "⏳ Container'ın başlamasını bekliyor..."
    sleep 10
    
    # Check status
    echo "📊 Container durumu:"
    docker-compose ps identity.api
    
    # Test health endpoint
    echo "🏥 Health check..."
    for i in {1..30}; do
        if curl -s http://localhost:5000/health > /dev/null; then
            echo "✅ BAŞARILI! Identity Server çalışıyor!"
            echo "🔗 Test URL: http://localhost:5000"
            break
        fi
        echo "  Deneme $i/30..."
        sleep 2
    done
    
    # Show logs if failed
    if ! curl -s http://localhost:5000/health > /dev/null; then
        echo "❌ Health check başarısız. Log'lar:"
        docker-compose logs --tail=20 identity.api
    fi
    
else
    echo "❌ Build başarısız!"
    echo "📝 Build log'larını kontrol edin."
fi

echo ""
echo "🎯 Sonuç: http://localhost:5000/health adresini test edin"
echo "📊 Container durumu: docker-compose ps identity.api"
echo "📝 Log'lar: docker-compose logs identity.api"
