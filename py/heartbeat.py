from python_modules.socket_ex import *

import struct
import time

HOST = "127.0.0.1"
PORT = 7410

client = create_client_with_name(HOST, PORT, __file__)
packet = struct.pack(">HHH", 6, 0, 0)

while True:
	client.sendall(packet)
	time.sleep(1)