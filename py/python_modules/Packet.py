
import struct
import json

class Packet():
	@static_method
	def NewBytes(msgId, clientId, msgData):
		if msgData:
			msgData = json.dumps(msgData)
			packet = struct.pack(">HHH", 6+len(msgData), msgId, clientId) + msgData
		else:
			packet = struct.pack(">HHH", 6, msgId, clientId)
		return packet

	def __init__(self, clientId, msgData, sock):
		self.clientId = clientId
		self.msgData = msgData
		self.sock = sock

	def send(self, ):
