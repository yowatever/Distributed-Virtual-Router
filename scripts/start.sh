# scripts/start.sh
#!/bin/bash

echo "=== Starting DVR System ==="

# Check if control plane is already running
if curl -s http://localhost:9090/health > /dev/null 2>&1; then
    echo "✅ Control Plane is already running on port 9090"
else
    echo "🚀 Starting Control Plane..."
    cd control-plane
    python control_plane.py &
    CP_PID=$!
    echo $CP_PID > ../control_plane.pid
    cd ..
    echo "✅ Control Plane started (PID: $CP_PID)"
    
    # Wait for control plane to start
    echo "⏳ Waiting for Control Plane to initialize..."
    sleep 3
fi

# Start Data Plane
echo ""
echo "🚀 Starting Data Plane..."
if [ -f "data-plane/build/dvr_data_plane" ]; then
    cd data-plane/build
    ./dvr_data_plane &
    DP_PID=$!
    echo $DP_PID > ../../data_plane.pid
    cd ../..
    echo "✅ Data Plane started (PID: $DP_PID) - C++ version"
elif [ -f "data-plane/build/dvr_data_plane.exe" ]; then
    cd data-plane/build
    ./dvr_data_plane.exe &
    DP_PID=$!
    echo $DP_PID > ../../data_plane.pid
    cd ../..
    echo "✅ Data Plane started (PID: $DP_PID) - C++ version"
elif [ -f "data-plane/data_plane.py" ]; then
    cd data-plane
    python data_plane.py &
    DP_PID=$!
    echo $DP_PID > ../data_plane.pid
    cd ..
    echo "✅ Data Plane started (PID: $DP_PID) - Python version"
else
    echo "❌ No data plane executable found. Please run build.sh first."
    exit 1
fi

echo ""
echo "🎉 DVR System is now running!"
echo "📊 Control Plane: http://localhost:9090"
echo "   - Health:    curl http://localhost:9090/health"
echo "   - Routes:    curl http://localhost:9090/routes"
echo "   - Stats:     curl http://localhost:9090/stats"
echo ""
echo "🛑 To stop the system: ./scripts/stop.sh"
echo "🧪 To test the system: ./scripts/test_api.sh"
