'''
logic - java
center - nodejs or python
gate - nodejs
heartbeat -python
843 - python
'''

import socket
import _thread

HOST = "127.0.0.1"
PORT = 7410

class Dispatcher:
	def __init__(self):
		self.lock = _thread.allocate_lock()
		self.notifyDict = {}

	def dispatch(self, sock, packet):
		self.lock.acquire()
		if controlFlag == 0:
			self.send(msgId, data)
		elif controlFlag == 1:
			self.regHandler(msgId, sock)
		elif controlFlag == 2:
			self.delHandler(msgId, sock)
		self.lock.release()

	def send(self, msgId, data)
		handlerList = self.notifyDict[msgId]
		if not handlerList:
			return
		for sock in handlerList:
			sock.sendall(data)

	def regHandler(self, msgId, sock):
		handlerList = self.notifyDict[msgId]
		if not handlerList:
			handlerList = set()
			self.notifyDict[msgId] = handlerList
		handlerList.add(sock)

	def delHandler(self, msgId, sock):
		handlerList = self.notifyDict[msgId]
		if not handlerList:
			return
		handlerList.remove(sock)


def client_loop(sock, address):
	recvBuff = bytes()
	headLen = 4
	begin = 0
	while True:
		try:
			data = sock.recv(0x10000)
		except ConnectionResetError:
			return
		if not data:
			return

		recvBuff += data
		end = len(recvBuff)

		while True:
			if end - begin < headLen:
				break
			packetLen = read_ushort(recvBuff, begin)
			if end - begin < packetLen:
				break;
			packet = recvBuff[begin+headLen:begin+packetLen]
			dispatcher.dispatch(sock, packet)
			begin += packetLen

		if begin > 0:
			recvBuff = recvBuff[begin:]
			begin = 0



dispatcher = Dispatcher()

server = socket.socket()
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(5)

while True:
	_thread.start_new_thread(client_loop, server.accept())