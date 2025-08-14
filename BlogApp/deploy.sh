#!/bin/bash

# FastAPI Blog Application Deployment Script
# This script automates the deployment process on Ubuntu

set -e  # Exit on any error

echo "🚀 Starting FastAPI Blog Application Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Run: sudo apt update && sudo apt install docker.io"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    echo "Run: sudo apt install docker-compose"
    exit 1
fi

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
    print_status "Creating data directory..."
    mkdir -p data
    chmod 755 data
fi

# Stop existing containers if running
print_status "Stopping existing containers..."
docker-compose down 2>/dev/null || true

# Build and start the application
print_status "Building and starting the application..."
docker-compose up -d --build

# Wait for the application to start
print_status "Waiting for application to start..."
sleep 10

# Check if the application is running
if docker-compose ps | grep -q "Up"; then
    print_status "✅ Application started successfully!"
    
    # Test the API
    print_status "Testing API endpoint..."
    if curl -s http://localhost:8000/blog > /dev/null; then
        print_status "✅ API is responding correctly!"
        echo ""
        echo "🎉 Deployment completed successfully!"
        echo ""
        echo "📋 Application Details:"
        echo "   - API URL: http://localhost:8000"
        echo "   - API Documentation: http://localhost:8000/docs"
        echo "   - Health Check: http://localhost:8000/blog"
        echo ""
        echo "📊 Container Status:"
        docker-compose ps
        echo ""
        echo "📝 To view logs: docker-compose logs -f"
        echo "🛑 To stop: docker-compose down"
    else
        print_warning "Application started but API is not responding yet. Please wait a moment and try again."
    fi
else
    print_error "❌ Failed to start the application!"
    echo ""
    echo "📋 Container Status:"
    docker-compose ps
    echo ""
    echo "📝 Logs:"
    docker-compose logs
    exit 1
fi
