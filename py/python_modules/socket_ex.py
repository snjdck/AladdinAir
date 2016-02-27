import socket
from os.path import basename

from .struct_ex import *

def create_server(host, port):
	sock = socket.socket()
	sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	sock.bind((host, port))
	sock.listen(0)
	return sock

def create_client(host, port):
	sock = socket.socket()
	sock.connect((host, port))
	return sock

def create_client_with_name(host, port, path):
	name = basename(path)[0:-3]
	packet = pack_ushort(2+len(name)) + name.encode()
	sock = create_client(host, port)
	sock.sendall(packet)
	return sock

def read_sock_forever(sock, queue):
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
			packetLen = read_ushort(recvBuff, begin)
			if end - begin < packetLen:
				break
			queue.put((sock, recvBuff[begin:begin+packetLen]))
			begin += packetLen

		if begin > 0:
			recvBuff = recvBuff[begin:]
			begin = 0