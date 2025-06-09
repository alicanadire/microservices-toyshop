#!/bin/bash

# Docker build fix script for EShop Microservices

echo "🔧 Fixing Docker build issues..."

# Stop all containers
echo "⏹️ Stopping existing containers..."
docker-compose down --remove-orphans 2>/dev/null || true

# Remove problematic images
echo "🗑️ Cleaning up Docker images..."
docker rmi identityapi 2>/dev/null || true
docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || true

# Prune build cache
echo "🧹 Cleaning build cache..."
docker builder prune -f

# Build only the Identity service first
echo "🏗️ Building Identity Service..."
docker-compose build identity.api

if [ $? -eq 0 ]; then
    echo "✅ Identity Service built successfully!"
    
    # Build all services
    echo "🏗️ Building all services..."
    docker-compose build --no-cache
    
    if [ $? -eq 0 ]; then
        echo "✅ All services built successfully!"
        
        # Start services
        echo "🚀 Starting services..."
        docker-compose up -d
        
        echo "🎉 Setup complete! Services starting..."
        echo ""
        echo "📊 Service Status:"
        sleep 5
        docker-compose ps
        
        echo ""
        echo "🔗 Access URLs:"
        echo "  Identity Service: https://localhost:5001"
        echo "  Shopping Web:     http://localhost:6005"
        echo "  API Gateway:      http://localhost:6004"
        
    else
        echo "❌ Failed to build all services"
        exit 1
    fi
else
    echo "❌ Failed to build Identity Service"
    echo ""
    echo "🔍 Troubleshooting tips:"
    echo "1. Make sure you're in the src directory"
    echo "2. Check if all project files exist"
    echo "3. Verify Docker is running"
    exit 1
fi
