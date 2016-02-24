from python_modules import *

HOST = "127.0.0.1"
PORT = 7410

class Dispatcher:
	def __init__(self):
		self.lock = allocate_lock()
		self.notifyDict = {}
		self.socketDict = {}

	def dispatch(self, sock, packet):
		if sock not in self.socketDict:
			self.socketDict[sock] = packet[2:].decode()
			return
		msgId = read_ushort(packet, 2)
		if msgId not in self.notifyDict:
			return
		self.lock.acquire()
		self.send(msgId, packet)
		self.lock.release()

	def send(self, msgId, packet):
		handlerList = self.notifyDict[msgId]
		for sock in self.socketDict.copy():
			if self.socketDict[sock] not in handlerList:
				continue
			try:
				sock.sendall(packet)
			except ConnectionResetError:
				del self.socketDict[sock]


def client_loop(sock, address):
	read_sock_forever(sock, dispatcher.dispatch)

dispatcher = Dispatcher()

dispatcher.notifyDict[0] = ["test", "gate"]

server = create_server(HOST, PORT)

while True:
	start_new_thread(client_loop, server.accept())