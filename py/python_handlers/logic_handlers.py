__all__ = []

from python_modules.handlerMgr import bindMsg
import struct

sendPacket = None

@bindMsg(0)
def heart_beat(clientId, msgData):
	print("heart beat")

@bindMsg(1)
def client_connect(clientId, msgData):
	print("client_connect")

@bindMsg(2)
def client_disconnect(clientId, msgData):
	print("client_disconnect")

@bindMsg(101)
def testMsg(clientId, msgData):
	packet = struct.pack(">HHH", 6, 102, clientId)
	sendPacket(packet)
	print("101 recv")
