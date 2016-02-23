'''
logic - java
center - nodejs or python
gate - nodejs
heartbeat -python
843 - python

total_len(2) + control(1) + msgId(2) + msgBody
'''

import socket
import struct
import _thread

HOST = "127.0.0.1"
PORT = 7410

class Dispatcher:
	def __init__(self):
		self.lock = _thread.allocate_lock()
		self.notifyDict = {}

	def dispatch(self, sock, packet):
		_, controlFlag, msgId = struct.unpack(">HBH", packet)
		self.lock.acquire()
		if controlFlag == 0:
			self.send(msgId, packet)
		elif controlFlag == 1:
			self.regHandler(msgId, sock)
		elif controlFlag == 2:
			self.delHandler(msgId, sock)
		self.lock.release()

	def send(self, msgId, packet):
		if msgId not in self.notifyDict:
			return
		handlerList = self.notifyDict[msgId]
		for sock in handlerList.copy():
			try:
				sock.sendall(packet)
			except ConnectionResetError:
				self.delAllHandlers(sock)

	def regHandler(self, msgId, sock):
		if msgId in self.notifyDict:
			handlerList = self.notifyDict[msgId]
		else:
			handlerList = set()
			self.notifyDict[msgId] = handlerList
		handlerList.add(sock)

	def delHandler(self, msgId, sock):
		if msgId not in self.notifyDict:
			return
		handlerList = self.notifyDict[msgId]
		handlerList.remove(sock)

	def delAllHandlers(self, sock):
		for msgId in self.notifyDict:
			handlerList = self.notifyDict[msgId]
			handlerList.remove(sock)


def client_loop(sock, address):
	recvBuff = bytes()
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
			if end - begin < 2:
				break
			packetLen = struct.unpack_from(">H", recvBuff, begin)[0]
			if end - begin < packetLen:
				break;
			packet = recvBuff[begin:begin+packetLen]
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