echo "=== Building DVR Data Plane (Simple) ==="

# Check if g++ is available
if command -v g++ &> /dev/null; then
    echo "🔨 Building Data Plane with g++..."
    cd data-plane
    g++ -std=c++17 -pthread -I include src/main.cpp src/data_plane.cpp -o dvr_data_plane_simple
    echo "✅ Data Plane built: data-plane/dvr_data_plane_simple"
    cd ..
else
    echo "❌ g++ not found. Please install MinGW-w64 or Visual Studio Build Tools"
    echo "   You can download MinGW from: https://www.mingw-w64.org/"
fi

echo "✅ Control Plane ready: control-plane/control_plane.py"
echo ""
echo "🎉 Build complete!"
