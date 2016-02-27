from python_modules.socket_ex import *

HOST = "127.0.0.1"
PORT = 843

server = create_server(HOST, PORT)

packet = b'<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>'

while True:
	client, address = server.accept()
	client.recv(0x20)
	client.sendall(packet)
	client.close()