from python_modules.socket_ex import *
from python_configs.server_address import *

server = create_server(address_server_843)

packet = b'<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>'

while True:
	client, address = server.accept()
	client.recv(0x20)
	client.sendall(packet)
	client.close()