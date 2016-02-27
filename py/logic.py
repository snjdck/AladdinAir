from python_modules.socket_ex import *
from python_modules.struct_ex import *
from python_modules.thread_ex import *
from python_modules import handlerMgr

from python_handlers import logic_handlers
from python_configs.server_address import *

from queue import Queue
import json

packetRecvQueue = Queue()
packetSendQueue = Queue()

logic_handlers.sendPacket = packetSendQueue.put

def handle_packet(sock, packet):
	packetLen = read_ushort(packet, 0)
	msgId = read_ushort(packet, 2)
	clientId = read_ushort(packet, 4)
	msgData = json.loads(packet[6:]) if packetLen > 6 else None
	handlerMgr.handleMsg(msgId, clientId, msgData)

client = create_client_with_name(address_server_center, __file__)
start_packet_send_thread(client.sendall, packetSendQueue)
start_packet_recv_thread(handle_packet,  packetRecvQueue)
read_sock_forever(client, packetRecvQueue)