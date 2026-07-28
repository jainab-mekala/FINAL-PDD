import http.server
import urllib.request
import urllib.error

class CORSProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Origin, Accept')
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length)
        
        target_url = 'https://api-implant-developed-1.onrender.com' + self.path
        
        req = urllib.request.Request(
            target_url,
            data=body,
            headers={'Content-Type': 'application/json'}
        )
        
        try:
            with urllib.request.urlopen(req) as response:
                resp_body = response.read()
                self.send_response(response.status)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(resp_body)
        except urllib.error.HTTPError as e:
            resp_body = e.read()
            self.send_response(e.code)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(resp_body)

if __name__ == '__main__':
    server_address = ('', 8080)
    httpd = http.server.HTTPServer(server_address, CORSProxyHandler)
    print("Local CORS proxy running on http://localhost:8080...")
    httpd.serve_forever()
