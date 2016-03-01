__all__ = []

from python_modules.handlerMgr import bindMsg
from python_modules.struct_ex import *

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
	sendPacket(pack_packet(102, clientId))
	print("101 recv")

@bindMsg(1001)
def testMsg(clientId, msgData):
	if msgData:
		print(msgData.decode())
	for uid in clientList:
		if uid == clientId:
			continue
		sendPacket(pack_packet(1002, uid, msgData))
		print("1001 recv")
