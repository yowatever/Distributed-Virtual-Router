# scripts/build.sh
#!/bin/bash

set -e

echo "=== Building DVR Project ==="

# Build Control Plane (Python - no compilation needed)
echo "✅ Control Plane ready: control-plane/control_plane.py (Python)"

# Build Data Plane (C++)
echo "🔨 Building Data Plane..."
cd data-plane

# Check for build directory and create if needed
mkdir -p build
cd build

# Check available compilers
if command -v g++ &> /dev/null; then
    echo "   Using g++ compiler..."
    g++ -std=c++17 -pthread -I ../include ../src/main.cpp ../src/data_plane.cpp -o dvr_data_plane
    echo "✅ Data Plane built: data-plane/build/dvr_data_plane"
elif command -v clang++ &> /dev/null; then
    echo "   Using clang++ compiler..."
    clang++ -std=c++17 -pthread -I ../include ../src/main.cpp ../src/data_plane.cpp -o dvr_data_plane
    echo "✅ Data Plane built: data-plane/build/dvr_data_plane"
elif command -v cl &> /dev/null; then
    echo "   Using MSVC compiler..."
    cl /EHsc /std:c++17 /I ../include ../src/main.cpp ../src/data_plane.cpp /Fe:dvr_data_plane.exe
    echo "✅ Data Plane built: data-plane/build/dvr_data_plane.exe"
else
    echo "⚠️  No C++ compiler found. Creating Python fallback..."
    cd ..
    cat > data_plane.py << 'EOF'
import time
import threading
from datetime import datetime

class DataPlane:
    def __init__(self):
        self.routes = {}
        self.running = False
        self.worker_thread = None
        self.packets_processed = 0
        self.routes_updated = 0
        
    def initialize(self):
        print("Initializing Data Plane...")
        self.add_route("10.0.0.0/24", "192.168.1.1", 100)
        self.add_route("172.16.0.0/16", "192.168.1.2", 200)
        print(f"Data Plane initialized with {len(self.routes)} default routes")
        return True
        
    def start(self):
        if self.running:
            return
            
        self.running = True
        self.worker_thread = threading.Thread(target=self.worker_loop)
        self.worker_thread.start()
        print("Data Plane started")
        
    def stop(self):
        if not self.running:
            return
            
        self.running = False
        if self.worker_thread:
            self.worker_thread.join()
        print("Data Plane stopped")
        
    def add_route(self, destination, next_hop, metric=100):
        self.routes[destination] = {
            'destination': destination,
            'next_hop': next_hop,
            'metric': metric
        }
        self.routes_updated += 1
        print(f"✓ Added route: {destination} -> {next_hop} (metric: {metric})")
        
    def delete_route(self, destination):
        if destination in self.routes:
            del self.routes[destination]
            self.routes_updated += 1
            print(f"✗ Deleted route: {destination}")
            return True
        else:
            print(f"! Route not found: {destination}")
            return False
            
    def get_routes(self):
        return list(self.routes.values())
        
    def show_stats(self):
        print("=== Data Plane Statistics ===")
        print(f"Packets processed: {self.packets_processed}")
        print(f"Routes updated: {self.routes_updated}")
        print(f"Active routes: {len(self.routes)}")
        
    def worker_loop(self):
        iteration = 0
        while self.running:
            time.sleep(2)
            self.packets_processed += 5
            
            if iteration % 5 == 0:
                print(f"Data plane processing packets... ({self.packets_processed} total)")
            iteration += 1

def main():
    print("🚀 Starting DVR Data Plane (Python)...")
    
    data_plane = DataPlane()
    
    if not data_plane.initialize():
        print("Failed to initialize data plane")
        return
        
    data_plane.start()
    
    print("Data plane running. Press Ctrl+C to stop.")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nShutting down data plane...")
        data_plane.stop()

if __name__ == '__main__':
    main()
EOF
    echo "✅ Python Data Plane created: data-plane/data_plane.py"
fi

cd ../..
echo ""
echo "🎉 Build complete!"
echo "📁 To run:"
echo "   Control Plane: python control-plane/control_plane.py"
echo "   Data Plane:    ./data-plane/build/dvr_data_plane (or python data-plane/data_plane.py)"
