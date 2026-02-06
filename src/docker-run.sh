#!/bin/bash

# EShop Microservices Docker Compose Runner
# This script helps you run the application in different modes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
MODE="development"
BUILD=false
LOGS=false
CLEAN=false

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -m, --mode MODE      Set the mode (development|production) [default: development]"
    echo "  -b, --build          Force rebuild of images"
    echo "  -l, --logs           Show logs after starting"
    echo "  -c, --clean          Clean up containers and volumes before starting"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0                             # Start in development mode"
    echo "  $0 --mode production --build   # Start in production mode with rebuild"
    echo "  $0 --clean --logs              # Clean start with logs"
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -b|--build)
            BUILD=true
            shift
            ;;
        -l|--logs)
            LOGS=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate mode
if [[ "$MODE" != "development" && "$MODE" != "production" ]]; then
    print_error "Invalid mode: $MODE. Must be 'development' or 'production'"
    exit 1
fi

print_info "Starting EShop Microservices in $MODE mode..."

# Set compose files based on mode
if [[ "$MODE" == "production" ]]; then
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.prod.yml"
    ENV_FILE=".env"
    
    # Check if .env file exists for production
    if [[ ! -f "$ENV_FILE" ]]; then
        print_warning ".env file not found. Creating from template..."
        cp .env.template .env
        print_warning "Please edit .env file with your production values before continuing."
        exit 1
    fi
else
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.override.yml"
fi

# Clean up if requested
if [[ "$CLEAN" == true ]]; then
    print_warning "Cleaning up containers and volumes..."
    docker-compose $COMPOSE_FILES down -v --remove-orphans
    docker system prune -f
    print_success "Cleanup completed"
fi

# Build if requested
if [[ "$BUILD" == true ]]; then
    print_info "Building images..."
    docker-compose $COMPOSE_FILES build --no-cache
    print_success "Build completed"
fi

# Start services
print_info "Starting services..."
if [[ "$BUILD" == true ]]; then
    docker-compose $COMPOSE_FILES up -d --build
else
    docker-compose $COMPOSE_FILES up -d
fi

# Wait for services to be ready
print_info "Waiting for services to be ready..."
sleep 10

# Check service health
print_info "Checking service health..."
services=("identity.api" "catalog.api" "basket.api" "discount.grpc" "ordering.api" "yarpapigateway" "shopping.web")

for service in "${services[@]}"; do
    if docker-compose $COMPOSE_FILES ps | grep -q "$service.*Up"; then
        print_success "$service is running"
    else
        print_error "$service failed to start"
    fi
done

print_success "EShop Microservices started successfully!"

# Show service URLs
echo ""
print_info "Service URLs:"
if [[ "$MODE" == "production" ]]; then
    echo "  Identity Service: https://identity.$DOMAIN_NAME"
    echo "  API Gateway:      https://api.$DOMAIN_NAME"
    echo "  Shopping Web:     https://$DOMAIN_NAME"
else
    echo "  Identity Service: https://localhost:5001"
    echo "  API Gateway:      http://localhost:6004"
    echo "  Shopping Web:     http://localhost:6005"
    echo "  Catalog API:      http://localhost:6000"
    echo "  Basket API:       http://localhost:6001"
    echo "  Discount gRPC:    http://localhost:6002"
    echo "  Ordering API:     http://localhost:6003"
fi

echo ""
print_info "Database URLs:"
echo "  Catalog DB:       localhost:5432"
echo "  Basket DB:        localhost:5433"
echo "  Identity DB:      localhost:5434"
echo "  Order DB:         localhost:1433"
echo "  Redis Cache:      localhost:6379"
echo "  RabbitMQ:         localhost:15672"

echo ""
print_info "Test Users:"
echo "  Admin:    admin@eshop.com / Password123!"
echo "  Customer: customer@eshop.com / Password123!"

# Show logs if requested
if [[ "$LOGS" == true ]]; then
    echo ""
    print_info "Showing logs (Press Ctrl+C to stop)..."
    docker-compose $COMPOSE_FILES logs -f
fi
