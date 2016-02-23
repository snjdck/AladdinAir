'''
logic - java
center - nodejs or python
gate - nodejs
heartbeat -python
843 - python

total_len(2) + control(1) + msgId(2) + msgBody
'''

import socket
import struct
import time

HOST = "127.0.0.1"
PORT = 7410

client = socket.socket()
client.connect((HOST, PORT))

packet = struct.pack(">HBH", 5, 1, 0)
client.sendall(packet)

while True:
	data = client.recv(0x10000)
	print(data)