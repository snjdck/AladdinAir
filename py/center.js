"use strict";

const serverPort = require("./node_configs/serverPort");
const notifyDict = require("./node_configs/notifyDict");
const net = require("net");
require("Socket");
const socketList = [];
const server = net.createServer(socket => {
	socket.readForever(onRecvPacket);
	socket.listenCloseEvent(1000, onSocketClose);
});
server.listen(serverPort.center_port, serverPort.center_host);
function onSocketClose(socket){
	var index = socketList.indexOf(socket);
	if(index >= 0)
		socketList.splice(index, 1);
}
function onRecvPacket(socket, packet){
	if(socketList.indexOf(socket) < 0){
		socket.setTimeout(0);
		socket.name = packet.toString("utf8", 2);
		socketList.push(socket);
		return;
	}
	var msgId = packet.readUInt16BE(2);
	var handlerList = notifyDict[msgId];
	if(handlerList == null || handlerList.length <= 0)
		return;
	for(var i=socketList.length-1; i>=0; --i){
		socket = socketList[i];
		if(handlerList.indexOf(socket.name) >= 0)
			socket.write(packet);
	}
}