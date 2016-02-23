import socket

HOST = "127.0.0.1"
PORT = 843

server = socket.socket()
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(5)

packet = b'<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>'

while True:
	client, address = server.accept()
	client.recv(0x20)
	client.sendall(packet)
	client.close()