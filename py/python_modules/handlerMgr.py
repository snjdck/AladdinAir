
__all__ = ["bindMsg"]

_handlerDict = {}

def bindMsg(msgId):
	def wrapper(func):
		_handlerDict[msgId] = func
		return func
	return wrapper

def handleMsg(msgId, clientId, msgData):
	if msgId not in _handlerDict:
		print("msgId not handled:", msgId)
		return
	handler = _handlerDict[msgId]
	handler(clientId, msgData)