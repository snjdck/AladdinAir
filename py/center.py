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
		self.notifyDict = {}

	def dispatch(self, msgId, data):
		handlerList = self.notifyDict[msgId]
		if not handlerList:
			return
		for client in handlerList:
			client.sendall(data)

	def addHandler(self, msgId, sock):
		handlerList = self.notifyDict[msgId]
		if not handlerList:
			handlerList = set()
			self.notifyDict[msgId] = handlerList
		handlerList.add(sock)

	def removeHandler(self, msgId, sock):
		handlerList = self.notifyDict[msgId]
		if not handlerList:
			return
		handlerList.remove(sock)


def client_read_loop(sock, address):
	while True:
		data = sock.recv(0x10000)
		if not data:
			return
		print(data)
		return
		lock.acquire()
		if controlFlag == 0:
			dispatcher.dispatch(msgId, data)
		elif controlFlag == 1:
			dispatcher.addHandler(msgId, sock)
		elif controlFlag == 2:
			dispatcher.removeHandler(msgId, sock)
		lock.release()


lock = _thread.allocate_lock()
dispatcher = Dispatcher()

server = socket.socket()
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((HOST, PORT))
server.listen(5)
while True:
	_thread.start_new_thread(client_read_loop, server.accept())