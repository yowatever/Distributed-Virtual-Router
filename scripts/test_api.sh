# scripts/test_api.sh
#!/bin/bash

echo "=== Testing DVR Control Plane API ==="

PORT=9090

# Check if control plane is running
echo "1. Checking Control Plane health..."
if curl -s http://localhost:$PORT/health > /dev/null; then
    echo "✅ Control plane is running on port $PORT"
else
    echo "❌ Control plane is not running on port $PORT"
    echo "   Start it with: ./scripts/start.sh"
    exit 1
fi

echo ""
echo "2. Testing all endpoints:"

echo ""
echo "   GET /health:"
curl -s http://localhost:$PORT/health | python -m json.tool

echo ""
echo "   GET /routes:"
curl -s http://localhost:$PORT/routes | python -m json.tool

echo ""
echo "   GET /stats:"
curl -s http://localhost:$PORT/stats | python -m json.tool

echo ""
echo "3. Testing route operations:"

echo ""
echo "   POST /routes - Adding test route:"
curl -s -X POST http://localhost:$PORT/routes \
  -H "Content-Type: application/json" \
  -d '{"destination": "192.168.100.0/24", "next_hop": "10.0.0.100", "metric": 150}' | python -m json.tool

echo ""
echo "   POST /routes - Adding another route:"
curl -s -X POST http://localhost:$PORT/routes \
  -H "Content-Type: application/json" \
  -d '{"destination": "192.168.200.0/24", "next_hop": "10.0.0.200", "metric": 250}' | python -m json.tool

echo ""
echo "   Updated routes:"
curl -s http://localhost:$PORT/routes | python -m json.tool

echo ""
echo "   DELETE /routes - Removing a route:"
curl -s -X DELETE "http://localhost:$PORT/routes?destination=192.168.100.0/24" | python -m json.tool

echo ""
echo "   Final routes:"
curl -s http://localhost:$PORT/routes | python -m json.tool

echo ""
echo "   Final stats:"
curl -s http://localhost:$PORT/stats | python -m json.tool

echo ""
echo "🎉 API tests completed successfully!"
echo "📊 Check the Control Plane terminal for operation logs"
