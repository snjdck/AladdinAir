import struct

def read_ushort(buffer, offset=0):
	return struct.unpack_from(">H", buffer, offset)[0]

def read_uint(buffer, offset=0):
	return struct.unpack_from(">I", buffer, offset)[0]

def pack_ushort(val):
	return struct.pack(">H", val)

def pack_uint(val):
	return struct.pack(">I", val)