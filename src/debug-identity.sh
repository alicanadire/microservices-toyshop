#!/bin/bash

echo "🔍 Identity Server Debug Mode"
echo "============================"

# Stop existing container
echo "🛑 Mevcut container'ı durduruyor..."
docker-compose stop identity.api 2>/dev/null
docker-compose rm -f identity.api 2>/dev/null

# Check database
echo "📊 Database durumunu kontrol ediyor..."
docker-compose ps identitydb

# Start database
echo "🗄️  Database'i başlatıyor..."
docker-compose up -d identitydb

echo "⏳ Database'in hazır olmasını bekliyor (30 saniye)..."
sleep 30

# Test database
echo "🧪 Database bağlantısını test ediyor..."
docker exec identitydb pg_isready -U postgres

# Rebuild and start
echo "🏗️  Identity Service'i rebuild ediyor..."
docker-compose build identity.api --no-cache

echo "🚀 Identity Service'i başlatıyor..."
docker-compose up identity.api
