# scripts/stop.sh
#!/bin/bash

echo "=== Stopping DVR System ==="

# Stop Control Plane
if [ -f "control_plane.pid" ]; then
    CP_PID=$(cat control_plane.pid)
    if ps -p $CP_PID > /dev/null 2>&1; then
        echo "🛑 Stopping Control Plane (PID: $CP_PID)..."
        kill $CP_PID
        rm control_plane.pid
    else
        echo "⚠️  Control Plane PID file exists but process not found"
        rm control_plane.pid
    fi
else
    echo "ℹ️  Control Plane PID file not found"
fi

# Stop Data Plane
if [ -f "data_plane.pid" ]; then
    DP_PID=$(cat data_plane.pid)
    if ps -p $DP_PID > /dev/null 2>&1; then
        echo "🛑 Stopping Data Plane (PID: $DP_PID)..."
        kill $DP_PID
        rm data_plane.pid
    else
        echo "⚠️  Data Plane PID file exists but process not found"
        rm data_plane.pid
    fi
else
    echo "ℹ️  Data Plane PID file not found"
fi

# Clean up any remaining processes
pkill -f "python control_plane.py" 2>/dev/null || true
pkill -f "python data_plane.py" 2>/dev/null || true
pkill -f "dvr_data_plane" 2>/dev/null || true

echo "✅ DVR System stopped"
