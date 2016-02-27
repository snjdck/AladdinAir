from python_modules.socket_ex import *
from python_modules.struct_ex import *
from python_modules.thread_ex import *

import struct
import time

HOST = "127.0.0.1"
PORT = 7411

client = create_client(HOST, PORT)
packet = struct.pack(">HHH", 6, 101, 0)

while True:
	client.sendall(packet)
	data = client.recv(0x10000)
	print(data)
	time.sleep(1)