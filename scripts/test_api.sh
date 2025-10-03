#!/bin/bash
# scripts/test_api.sh

echo "=== Testing DVR Control Plane API ==="

# Check if control plane is running
if ! curl -s http://localhost:8080/health > /dev/null; then
    echo "❌ Control plane is not running on port 8080"
    echo "   Start it with: python control-plane/control_plane.py"
    exit 1
fi

echo "✅ Control plane is running"

echo ""
echo "1. Testing /health endpoint:"
curl -s http://localhost:8080/health | python -m json.tool

echo ""
echo "2. Testing /routes endpoint (GET):"
curl -s http://localhost:8080/routes | python -m json.tool

echo ""
echo "3. Testing /stats endpoint:"
curl -s http://localhost:8080/stats | python -m json.tool

echo ""
echo "4. Testing route addition (POST):"
curl -s -X POST http://localhost:8080/routes \
  -H "Content-Type: application/json" \
  -d '{"destination": "192.168.100.0/24", "next_hop": "10.0.0.100", "metric": 150}' | python -m json.tool

echo ""
echo "5. Updated routes:"
curl -s http://localhost:8080/routes | python -m json.tool

echo ""
echo "🎉 API tests completed!"
