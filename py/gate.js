"use strict"

var gate_host = "127.0.0.1";
var gate_port = 7411;

var center_host = "127.0.0.1";
var center_port = 7410;

var net = require("net");
var Packet = require("Packet");
require("Socket");

var socketDict = {};
var nextSocketId = 0;

var server = new net.Server();
server.listen(gate_port, gate_host);

var centerSocket = new net.Socket();
centerSocket.connect(center_port, center_host);

centerSocket.on("connect", function(){
	centerSocket.write(Packet.CreateNamePacket("gate"));
});
centerSocket.readForever(function(_, packet){
	var msgId = packet.readUInt16BE(2);
	var socketId = packet.readUInt16BE(4);
	var socket = socketDict[socketId];
	if(socket != null)
		socket.write(packet);
});
server.on("connection", function(socket){
	socket.uid = nextSocketId++;
	socketDict[socket.uid] = socket;
	centerSocket.write(Packet.CreateClientConnectPacket(socket.uid));
	socket.readForever(forwardClientPacket);
	socket.on("close", function(){
		closeClient(socket);
	});
	socket.on("error", function(err){
		//closeClient(socket);
	});
});
server.on("error", function(err){
	switch(err.code){
		case "EADDRINUSE":
			console.error('Address in use, retrying...');
			break;
		default:
			console.error("socket server error!", err);
	}
});
function forwardClientPacket(socket, packet){
	packet.writeUInt16BE(socket.uid, 4);
	centerSocket.write(packet);
}
function closeClient(socket){
	socket.removeAllListeners();
	centerSocket.write(Packet.CreateClientClosePacket(socket.uid));
	delete socketDict[socket.uid];
}