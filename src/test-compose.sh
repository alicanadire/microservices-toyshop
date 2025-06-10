#!/bin/bash

echo "🧪 Docker Compose Test"
echo "====================="

# Test compose configuration
echo "📋 Testing docker-compose configuration..."
docker-compose config

if [ $? -eq 0 ]; then
    echo "✅ Docker Compose configuration is valid!"
    
    echo ""
    echo "🚀 Starting services..."
    docker-compose up -d
    
    echo ""
    echo "📊 Service status:"
    docker-compose ps
    
else
    echo "❌ Docker Compose configuration has errors!"
    exit 1
fi
