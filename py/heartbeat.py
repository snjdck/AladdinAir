import socket
import struct
import time

HOST = "127.0.0.1"
PORT = 7410

client = socket.socket()
client.connect((HOST, PORT))

packet = struct.pack(">HBH", 5, 0, 0)

while True:
	client.sendall(packet)
	time.sleep(1)