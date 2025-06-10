#!/bin/bash

echo "🔧 Identity Server Build Fix"
echo "==========================="

# Stop existing containers
echo "🛑 Mevcut container'ları durduruyor..."
docker-compose down --remove-orphans

# Clean Docker cache for Identity service
echo "🧹 Identity Service cache'ini temizliyor..."
docker rmi $(docker images | grep identityapi | awk '{print $3}') 2>/dev/null || true

# Test build locally first
echo "🧪 Local build test..."
cd Services/Identity/Identity.API/
dotnet restore
dotnet build

if [ $? -eq 0 ]; then
    echo "✅ Local build başarılı!"
    cd ../../../
    
    # Now try Docker build
    echo "🐳 Docker build test..."
    docker-compose build identity.api --no-cache
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker build başarılı!"
        
        # Start infrastructure
        echo "🏗️  Infrastructure başlatılıyor..."
        docker-compose up -d identitydb
        sleep 15
        
        # Start Identity service
        echo "🚀 Identity service başlatılıyor..."
        docker-compose up -d identity.api
        
        # Check status
        echo "📊 Status kontrolü..."
        sleep 10
        docker-compose ps identity.api
        
        # Test endpoint
        echo "🧪 Endpoint test..."
        curl -f http://localhost:5000/health || echo "Endpoint henüz hazır değil..."
        
    else
        echo "❌ Docker build başarısız!"
    fi
else
    echo "❌ Local build başarısız!"
    echo "Dependencies kontrol ediliyor..."
    cd ../../../
fi

echo ""
echo "🔍 Identity container durumu:"
docker-compose ps identity.api

echo ""
echo "📝 Log kontrolü için:"
echo "docker-compose logs identity.api"
