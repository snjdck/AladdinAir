from python_modules.socket_ex import *
from python_modules.struct_ex import *
from python_modules.file_ex import *

import time

address_server_center = load_socket_address("./node_configs/serverPort.json", "center_host", "center_port")
client = create_client_with_name(address_server_center, __file__)
packet = pack_packet(0, 0)

while True:
	client.sendall(packet)
	time.sleep(1)