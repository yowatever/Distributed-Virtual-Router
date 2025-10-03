# control-plane/control_plane.py
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import threading
from datetime import datetime

class Route:
    def __init__(self, destination, next_hop, metric=100):
        self.destination = destination
        self.next_hop = next_hop
        self.metric = metric
    
    def to_dict(self):
        return {
            'destination': self.destination,
            'next_hop': self.next_hop,
            'metric': self.metric
        }

class ControlPlane:
    def __init__(self):
        self.routes = {}
        self.stats = {
            'start_time': datetime.now().isoformat(),
            'routes_added': 0,
            'routes_deleted': 0,
            'api_requests': 0
        }
        self.lock = threading.Lock()
        
        # Add default routes
        self.add_route(Route("10.0.0.0/24", "192.168.1.1", 100))
        self.add_route(Route("172.16.0.0/16", "192.168.1.2", 200))
    
    def add_route(self, route):
        with self.lock:
            self.routes[route.destination] = route
            self.stats['routes_added'] += 1
            print(f"✓ Route added: {route.destination} -> {route.next_hop} (metric: {route.metric})")
    
    def delete_route(self, destination):
        with self.lock:
            if destination in self.routes:
                del self.routes[destination]
                self.stats['routes_deleted'] += 1
                print(f"✗ Route deleted: {destination}")
                return True
            return False
    
    def get_routes(self):
        with self.lock:
            return [route.to_dict() for route in self.routes.values()]
    
    def get_stats(self):
        with self.lock:
            return self.stats.copy()

class DVRRequestHandler(BaseHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        self.control_plane = ControlPlane()
        super().__init__(*args, **kwargs)
    
    def do_GET(self):
        self.control_plane.stats['api_requests'] += 1
        
        if self.path == '/routes':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(self.control_plane.get_routes()).encode())
        
        elif self.path == '/stats':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(self.control_plane.get_stats()).encode())
        
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'healthy'}).encode())
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_POST(self):
        self.control_plane.stats['api_requests'] += 1
        
        if self.path == '/routes':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                route_data = json.loads(post_data)
                route = Route(
                    route_data['destination'],
                    route_data['next_hop'],
                    route_data.get('metric', 100)
                )
                self.control_plane.add_route(route)
                
                self.send_response(201)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'status': 'route added'}).encode())
            
            except Exception as e:
                self.send_response(400)
                self.end_headers()
                self.wfile.write(str(e).encode())
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def do_DELETE(self):
        self.control_plane.stats['api_requests'] += 1
        
        if self.path.startswith('/routes'):
            from urllib.parse import urlparse, parse_qs
            parsed = urlparse(self.path)
            params = parse_qs(parsed.query)
            
            destination = params.get('destination', [None])[0]
            if destination and self.control_plane.delete_route(destination):
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'status': 'route deleted'}).encode())
            else:
                self.send_response(404)
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'route not found'}).encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")

def main():
    port = 8080
    server = HTTPServer(('localhost', port), DVRRequestHandler)
    
    print(f"🚀 DVR Control Plane (Python) starting on http://localhost:{port}")
    print(f"📊 Available endpoints:")
    print(f"   GET  http://localhost:{port}/routes  - List all routes")
    print(f"   POST http://localhost:{port}/routes  - Add a route")
    print(f"   DELETE http://localhost:{port}/routes?destination=X - Delete a route")
    print(f"   GET  http://localhost:{port}/stats   - Get statistics")
    print(f"   GET  http://localhost:{port}/health  - Health check")
    print(f"Press Ctrl+C to stop the server")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Shutting down DVR Control Plane...")
        server.shutdown()

if __name__ == '__main__':
    main()
