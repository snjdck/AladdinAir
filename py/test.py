from python_modules import *
import struct

HOST = "127.0.0.1"
PORT = 7410

client = create_client_with_name(HOST, PORT, __file__)

while True:
	data = client.recv(0x10000)
	clientId = read_ushort(data, 4)
	packet = struct.pack(">HHH", 6, 102, clientId)
	client.sendall(packet)