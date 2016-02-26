from python_modules import *

HOST = "127.0.0.1"
PORT = 7410

lock = allocate_lock()
notifyDict = {}
socketDict = {}

notifyDict[0] = ["test", "gate"]
notifyDict[1] = ["test"]
notifyDict[2] = ["test"]
notifyDict[101] = ["test"]

def dispatch(sock, packet):
	if sock not in socketDict:
		socketDict[sock] = packet[2:].decode()
		return
	msgId = read_ushort(packet, 2)
	if msgId not in notifyDict:
		return
	handlerList = notifyDict[msgId]
	with lock:
		for sock in socketDict.copy():
			if socketDict[sock] not in handlerList:
				continue
			try:
				sock.sendall(packet)
			except ConnectionResetError:
				del socketDict[sock]

def client_loop(sock, address):
	read_sock_forever(sock, dispatch)
	with lock:
		if sock in socketDict:
			del socketDict[sock]

server = create_server(HOST, PORT)
while True:
	start_new_thread(client_loop, server.accept())