from python_modules import *
from queue import Queue

HOST = "127.0.0.1"
PORT = 7410

packetQueue = Queue()
notifyDict = {}
socketDict = {}

notifyDict[0] = ["test", "gate"]
notifyDict[1] = ["test"]
notifyDict[2] = ["test"]
notifyDict[101] = ["test"]

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

def packet_loop():
	while True:
		handle_packet(*packetQueue.get())

def client_loop(sock, address):
	read_sock_forever(sock, packetQueue)
	packetQueue.put((sock, None))

server = create_server(HOST, PORT)
start_new_thread(packet_loop, ())
while True:
	start_new_thread(client_loop, server.accept())