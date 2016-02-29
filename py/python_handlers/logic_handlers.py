__all__ = []

from python_modules.handlerMgr import bindMsg
import struct
import json

sendPacket = None

clientList = []

@bindMsg(0)
def heart_beat(clientId, msgData):
	print("heart beat")

@bindMsg(1)
def client_connect(clientId, msgData):
	print("client_connect")
	clientList.append(clientId)

@bindMsg(2)
def client_disconnect(clientId, msgData):
	print("client_disconnect")
	clientList.remove(clientId)

@bindMsg(101)
def testMsg(clientId, msgData):
	packet = struct.pack(">HHH", 6, 102, clientId)
	sendPacket(packet)
	print("101 recv")

@bindMsg(1001)
def testMsg(clientId, msgData):
	if msgData:
		print(msgData.decode())
	for uid in clientList:
		if uid == clientId:
			continue
		#packet = json.dumps(msgData)
		packet = struct.pack(">HHH", 6+len(msgData), 1002, uid) + msgData
		sendPacket(packet)
		print("1001 recv")
