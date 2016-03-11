import struct
import json

def read_ushort(buffer, offset=0):
	return struct.unpack_from(">H", buffer, offset)[0]

def read_uint(buffer, offset=0):
	return struct.unpack_from(">I", buffer, offset)[0]

def pack_ushort(val):
	return struct.pack(">H", val)

def pack_uint(val):
	return struct.pack(">I", val)

def read_json(buffer):
	return json.loads(buffer.decode())

def pack_json(val):
	return json.dumps(val).encode()

def read_packet(buffer):
	packetLen = read_ushort(buffer, 0)
	msgId = read_ushort(buffer, 2)
	clientId = read_ushort(buffer, 4)
	msgData = buffer[6:] if packetLen > 6 else None
	return (msgId, clientId, msgData)

def pack_packet(msgId, clientId, msgData=None):
	packetLen = 6
	if msgData:
		packetLen += len(msgData)
	buffer = struct.pack(">HHH", packetLen, msgId, clientId)
	if msgData:
		buffer += msgData
	return buffer

def read_packet_json(buffer):
	msgId, clientId, msgData = read_packet(buffer)
	if msgData:
		msgData = read_json(msgData)
	return (msgId, clientId, msgData)

def pack_packet_json(msgId, clientId, msgData=None):
	if msgData:
		msgData = pack_json(msgData)
	return pack_packet(msgId, clientId, msgData)