"use strict";

const serverPort = require("./node_configs/serverPort");
const notifyDict = require("./node_configs/notifyDict");
const net = require("net");
require("Socket");
const socketList = [];
const server = net.createServer(function(socket){
	function onClose(err){
		socket.removeAllListeners();
		var index = socketList.indexOf(socket);
		if(index >= 0){
			socketList.splice(index, 1);
		}
	}
	socket.on("close", onClose);
	socket.on("error", onClose);
	socket.readForever(onRecvPacket);
});
function onRecvPacket(socket, packet){
	if(socketList.indexOf(socket) < 0){
		socket.name = packet.toString("utf8", 2);
		socketList.push(socket);
		return;
	}
	var msgId = packet.readUInt16BE(2);
	var handlerList = notifyDict[msgId];
	for(var i=socketList.length-1; i>=0; --i){
		var client = socketList[i];
		if(handlerList.indexOf(client.name) >= 0)
			client.write(packet);
	}
}
server.listen(serverPort.center_port, serverPort.center_host);