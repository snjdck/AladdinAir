from python_modules.socket_ex import *
from python_modules.struct_ex import *
from python_modules.thread_ex import *

import time
import json

with open("./node_configs/serverPort.json") as f:
	serverPort = json.load(f)
address_server_gate = (serverPort["gate_host"], serverPort["gate_port"])

client = create_client(address_server_gate)
packet = pack_packet(101, 0)

while True:
	client.sendall(packet)
	data = client.recv(0x10000)
	print(data)
	time.sleep(1)