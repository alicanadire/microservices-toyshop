#!/bin/bash

echo "🔨 Quick Build Test"
echo "=================="

echo "🧹 Cleaning old images..."
docker-compose down --remove-orphans
docker system prune -f

echo "🏗️ Building Identity Service..."
docker-compose build identity.api --no-cache

if [ $? -eq 0 ]; then
    echo "✅ Identity Service build successful!"
    
    echo "🏗️ Building other services..."
    docker-compose build --no-cache
    
    if [ $? -eq 0 ]; then
        echo "✅ All services built successfully!"
        
        echo "🚀 Starting services..."
        docker-compose up -d
        
        echo "📊 Service status:"
        docker-compose ps
        
        echo ""
        echo "🧪 Testing endpoints..."
        sleep 10
        curl -s http://localhost:6006/health && echo " ✅ Identity Server"
        curl -s http://localhost:6064/health && echo " ✅ API Gateway"
        curl -s http://localhost:5000 && echo " ✅ Shopping Web"
        
    else
        echo "❌ Build failed!"
    fi
else
    echo "❌ Identity Service build failed!"
fi
