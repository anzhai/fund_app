#!/bin/bash
# Start all backend services for development

cd "$(dirname "$0")"

# Set environment variables for local development
export DATABASE_URL="sqlite:///./fund_app_dev.db"
export REDIS_URL="redis://localhost:6379"
export JWT_SECRET="dev-secret-key-change-in-production"

# Function to start a service
start_service() {
    local service=$1
    local port=$2
    local dir=$3

    echo "Starting $service on port $port..."
    cd "$dir"
    nohup python3 -m uvicorn main:app --host 0.0.0.0 --port $port > "$service.log" 2>&1 &
    cd - > /dev/null
    sleep 1
}

# Kill any existing services on these ports
for port in 8001 8002 8003 8004 8005; do
    pid=$(lsof -ti:$port 2>/dev/null)
    if [ -n "$pid" ]; then
        echo "Killing existing process on port $port..."
        kill $pid 2>/dev/null
    fi
done

# Install dependencies if needed
for dir in auth-service account-service fund-service portfolio-service trade-service; do
    if [ -f "$dir/requirements.txt" ]; then
        pip3 install -q -r "$dir/requirements.txt" 2>/dev/null
    fi
done

# Start all services
start_service "auth-service" 8001 "auth-service"
start_service "account-service" 8002 "account-service"
start_service "fund-service" 8003 "fund-service"
start_service "portfolio-service" 8004 "portfolio-service"
start_service "trade-service" 8005 "trade-service"

echo ""
echo "All services starting..."
sleep 3

# Check health of all services
echo ""
echo "Service health checks:"
for port in 8001 8002 8003 8004 8005; do
    curl -s http://localhost:$port/health 2>/dev/null && echo " (port $port)" || echo "FAIL (port $port)"
done

echo ""
echo "Services are running. Logs are in each service directory."
echo "To stop: pkill -f 'uvicorn main:app'"