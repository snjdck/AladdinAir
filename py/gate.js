"use strict";

const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const socketDict = {};
var nextSocketId = 0;

const server = net.createServer(function(socket){
	socket.uid = nextSocketId++;
	socketDict[socket.uid] = socket;
	centerSocket.write(Packet.CreateClientConnectPacket(socket.uid));
	socket.readForever(forwardClientPacket);
	function onClose(err){
		socket.removeAllListeners();
		centerSocket.write(Packet.CreateClientClosePacket(socket.uid));
		delete socketDict[socket.uid];
	}
	socket.on("close", onClose);
	socket.on("error", onClose);
});
server.listen(serverPort.gate_port, serverPort.gate_host);

const centerSocket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	centerSocket.write(Packet.CreateNamePacket("gate"));
});
centerSocket.readForever(function(_, packet){
	var msgId = packet.readUInt16BE(2);
	var socketId = packet.readUInt16BE(4);
	var socket = socketDict[socketId];
	if(socket != null)
		socket.write(packet);
});
function forwardClientPacket(socket, packet){
	packet.writeUInt16BE(socket.uid, 4);
	centerSocket.write(packet);
}