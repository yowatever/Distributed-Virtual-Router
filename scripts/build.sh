#!/bin/bash
# scripts/build.sh

echo "=== Building DVR Project ==="

# Build Data Plane (C++)
echo "🔨 Building Data Plane..."
cd data-plane
mkdir -p build
cd build

# Check if cmake is available
if command -v cmake &> /dev/null; then
    cmake ..
    make -j4
    echo "✅ Data Plane built: data-plane/build/dvr_data_plane"
else
    echo "⚠️  CMake not found. Please install CMake to build the data plane."
    echo "   On Windows, you can install it from: https://cmake.org/download/"
fi

cd ../..

# Control Plane (Python) doesn't need compilation
echo "✅ Control Plane ready: control-plane/control_plane.py (Python)"
echo ""
echo "🎉 Build complete!"
echo "📁 To run:"
echo "   Control Plane: python control-plane/control_plane.py"
echo "   Data Plane:    ./data-plane/build/dvr_data_plane"
