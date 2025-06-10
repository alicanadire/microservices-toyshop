#!/bin/bash

echo "🚀 EShop Microservices Startup Script"
echo "====================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✅ Docker is running"

# Clean up existing containers
echo "🧹 Cleaning up existing containers..."
docker-compose -f docker-compose.yml -f docker-compose.override.yml down --remove-orphans 2>/dev/null

# Remove any existing containers that might conflict
echo "🗑️  Removing old containers..."
docker-compose -f docker-compose.yml -f docker-compose.override.yml rm -f 2>/dev/null

# Start infrastructure services first
echo "🏗️  Starting infrastructure services..."
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d identitydb catalogdb basketdb orderdb distributedcache messagebroker

# Wait for databases
echo "⏳ Waiting for databases to be ready..."
sleep 10

# Build and start application services
echo "🏗️  Building application services..."
docker-compose -f docker-compose.yml -f docker-compose.override.yml build --no-cache

echo "🚀 Starting all services..."
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d

echo ""
echo "⏳ Services are starting up. This may take a few minutes..."
echo ""

# Wait for services to be ready
echo "⏳ Waiting for key services..."
sleep 30

# Show status
echo ""
echo "📊 Container Status:"
docker-compose -f docker-compose.yml -f docker-compose.override.yml ps

echo ""
echo "🎉 EShop Microservices Started Successfully!"
echo "=========================================="
echo ""
echo "🌐 Access URLs:"
echo "  🛒 Shopping Web:     http://localhost:6005"
echo "  🔑 Identity Service: http://localhost:5000"
echo "  🚪 API Gateway:      http://localhost:6004"
echo ""
echo "👤 Test Users:"
echo "  👨‍💼 Admin:           admin@eshop.com / Password123!"
echo "  👤 Customer:        customer@eshop.com / Password123!"
echo ""
echo "🎯 Open http://localhost:6005 in your browser to start shopping!"
echo ""
