
from python_modules.socket_ex import *
from python_modules.struct_ex import *
from python_modules.thread_ex import *

from python_configs.center_server import notifyDict
from python_configs.server_address import *

from queue import Queue

packetQueue = Queue()
socketDict = {}

def handle_packet(sock, packet):
	if not packet:
		if sock in socketDict:
			del socketDict[sock]
		return
	if sock not in socketDict:
		socketDict[sock] = packet[2:].decode()
		return
	msgId = read_ushort(packet, 2)
	if msgId not in notifyDict:
		return
	handlerList = notifyDict[msgId]
	for sock in socketDict:
		if socketDict[sock] not in handlerList:
			continue
		try:
			sock.sendall(packet)
		except ConnectionResetError:
			packetQueue.put((sock, None))

def thread_client(sock, address):
	read_sock_forever(sock, packetQueue)
	packetQueue.put((sock, None))

server = create_server(address_server_center)
start_packet_recv_thread(handle_packet, packetQueue)
while True:
	start_new_thread(thread_client, server.accept())