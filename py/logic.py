from python_modules.socket_ex import *
from python_modules.struct_ex import *
from python_modules.thread_ex import *
from python_modules import handlerMgr

from python_handlers import logic_handlers

from queue import Queue
import json

with open("./node_configs/serverPort.json") as f:
	serverPort = json.load(f)
address_server_center = (serverPort["center_host"], serverPort["center_port"])

packetRecvQueue = Queue()
packetSendQueue = Queue()

logic_handlers.sendPacket = packetSendQueue.put

def handle_packet(sock, packet):
	handlerMgr.handleMsg(*read_packet(packet))

client = create_client_with_name(address_server_center, __file__)
start_packet_send_thread(client.sendall, packetSendQueue)
start_packet_recv_thread(handle_packet,  packetRecvQueue)
read_sock_forever(client, packetRecvQueue)