from python_modules.socket_ex import *
from python_configs.server_address import *

import struct
import time

client = create_client_with_name(address_server_center, __file__)
packet = struct.pack(">HHH", 6, 0, 0)

while True:
	client.sendall(packet)
	time.sleep(1)