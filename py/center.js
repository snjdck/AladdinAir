"use strict";

const serverPort = require("./node_configs/serverPort");
const notifyDict = require("./node_configs/config").notifyDict;
const Packet = require("Packet");
require("Socket");

require("net").createServer(socket => {
	socket.readForever(onRecvPacket);
	socket.listenCloseEvent(1000, onSocketClose);
}).listen(serverPort.center_port, serverPort.center_host);

const socketList = [];

function onSocketClose(socket){
	var index = socketList.indexOf(socket);
	if(index >= 0)
		socketList.splice(index, 1);
}

function onRecvPacket(packet){
	if(socketList.indexOf(this) < 0){
		this.setTimeout(0);
		this.name = packet.toString("utf8", 2);
		socketList.push(this);
		return;
	}
	var msgId = Packet.ReadMsgId(packet);
	var handlerList = notifyDict[msgId];
	if(handlerList == null || handlerList.length <= 0)
		return;
	for(var i=socketList.length-1; i>=0; --i){
		var socket = socketList[i];
		if(handlerList.indexOf(socket.name) >= 0)
			socket.write(packet);
	}
}