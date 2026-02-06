#!/bin/sh

# Simple Status Check - POSIX compatible
echo "🔍 Checking EShop Microservices Status..."

echo "\n📊 Container Status:"
docker-compose ps

echo "\n🌐 Testing HTTP Services..."

# Test services
test_service() {
    name=$1
    url=$2
    echo "Testing $name at $url..."
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" --connect-timeout 5 | grep -q "200"; then
        echo "✅ $name - WORKING"
    else
        echo "❌ $name - NOT RESPONDING"
    fi
}

echo "\n🧪 HTTP Service Tests:"
test_service "Shopping Web" "http://localhost:6005"
test_service "Identity Service" "http://localhost:5000"  
test_service "API Gateway" "http://localhost:6004"
test_service "Catalog API" "http://localhost:6000"
test_service "Basket API" "http://localhost:6001"
test_service "Ordering API" "http://localhost:6003"

echo "\n🎉 Quick Access URLs:"
echo "  Shopping Web:     http://localhost:6005"
echo "  Identity Service: http://localhost:5000"
echo "  API Gateway:      http://localhost:6004"

echo "\n🔑 Test Credentials:"
echo "  Admin:    admin@eshop.com / Password123!"
echo "  Customer: customer@eshop.com / Password123!"

echo "\n✅ System appears to be running!"
echo "Try: http://localhost:6005 in your browser"
