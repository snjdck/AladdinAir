import _thread
import socket
import struct
import os

start_new_thread	= _thread.start_new_thread
allocate_lock		= _thread.allocate_lock

def read_sock_forever(sock, handler):
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
			handler(sock, recvBuff[begin:begin+packetLen])
			begin += packetLen

		if begin > 0:
			recvBuff = recvBuff[begin:]
			begin = 0

def create_client_with_name(host, port, path):
	name = os.path.basename(path)[0:-3]
	sock = create_client(host, port)
	sock.sendall(pack_ushort(len(name) + 2) + name.encode())
	return sock

def create_client(host, port):
	sock = socket.socket()
	sock.connect((host, port))
	return sock

def create_server(host, port):
	sock = socket.socket()
	sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	sock.bind((host, port))
	sock.listen(0)
	return sock

def read_ushort(buffer, offset=0):
	return struct.unpack_from(">H", buffer, offset)[0]

def read_uint(buffer, offset=0):
	return struct.unpack_from(">I", buffer, offset)[0]

def pack_ushort(val):
	return struct.pack(">H", val)

def pack_uint(val):
	return struct.pack(">I", val)