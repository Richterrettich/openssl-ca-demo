from http.server import HTTPServer, SimpleHTTPRequestHandler
from ssl import PROTOCOL_TLS_SERVER, SSLContext
import sys

ssl_context = SSLContext(PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain(sys.argv[1], sys.argv[2])
server = HTTPServer(("0.0.0.0", 8443), SimpleHTTPRequestHandler)
server.socket = ssl_context.wrap_socket(server.socket, server_side=True)
server.serve_forever()