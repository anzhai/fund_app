#!/bin/bash

# Fund App Local Development Start Script

set -e

echo "=========================================="
echo "  基金组合管理 App - 本地启动脚本"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter is not installed. Skipping frontend setup."
    FLUTTER_AVAILABLE=false
else
    FLUTTER_AVAILABLE=true
fi

cd "$(dirname "$0")"

# Backend Setup
echo "📦 Setting up backend services..."
echo ""

# Create .env file if not exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env file and set JWT_SECRET before continuing."
    echo ""
    read -p "Press Enter to continue after editing .env..."
fi

# Build and start Docker containers
echo "🚀 Starting backend services with Docker Compose..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo ""
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "✅ Backend services started!"
echo ""
echo "Service URLs:"
echo "  - Auth Service:     http://localhost:8001"
echo "  - Account Service:  http://localhost:8002"
echo "  - Fund Service:     http://localhost:8003"
echo "  - Portfolio Service: http://localhost:8004"
echo "  - Trade Service:    http://localhost:8005"
echo "  - API Gateway:      http://localhost:80"
echo ""
echo "Swagger Docs:"
echo "  - Auth:             http://localhost:8001/docs"
echo "  - Account:          http://localhost:8002/docs"
echo "  - Fund:             http://localhost:8003/docs"
echo "  - Portfolio:        http://localhost:8004/docs"
echo "  - Trade:            http://localhost:8005/docs"
echo ""

# Seed mock data
echo "📊 Seeding mock fund data..."
curl -s -X POST http://localhost:8003/fund/seed || echo "⚠️  Failed to seed data (service might still be starting)"
echo ""

# Frontend Setup
if [ "$FLUTTER_AVAILABLE" = true ]; then
    echo "📱 Setting up Flutter frontend..."
    cd frontend/fund_app
    
    echo "Installing Flutter dependencies..."
    flutter pub get
    
    echo ""
    echo "✅ Flutter dependencies installed!"
    echo ""
    echo "To run the Flutter app:"
    echo "  cd frontend/fund_app"
    echo "  flutter run"
    echo ""
    
    cd ../..
else
    echo "⚠️  Flutter not available. Skipping frontend setup."
    echo "   To run the frontend manually:"
    echo "   cd frontend/fund_app"
    echo "   flutter pub get"
    echo "   flutter run"
    echo ""
fi

echo "=========================================="
echo "  🎉 Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Open browser to test APIs: http://localhost:8003/docs"
echo "2. Run Flutter app on emulator/device"
echo "3. Check logs: docker-compose logs -f"
echo ""
echo "To stop all services:"
echo "  docker-compose down"
echo ""
