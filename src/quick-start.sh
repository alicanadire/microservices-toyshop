#!/bin/bash

echo "🚀 Starting EShop Microservices..."
echo "================================="

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found. Make sure you're in the src directory."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose down --remove-orphans 2>/dev/null

# Start infrastructure services first
echo "🏗️  Starting infrastructure (databases, redis, rabbitmq)..."
docker-compose up -d identitydb catalogdb basketdb orderdb distributedcache messagebroker

# Wait for databases to be ready
echo "⏳ Waiting for databases to start..."
sleep 15

# Build and start application services
echo "🏗️  Building and starting application services..."
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready (this may take 2-3 minutes)..."
sleep 30

echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "🎉 Services should be ready now!"
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
echo "🔧 If services don't work, check logs with:"
echo "  docker-compose logs [service-name]"
echo ""
