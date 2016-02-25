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

var centerSocket = new net.Socket();
centerSocket.connect(center_port, center_host);

centerSocket.on("connect", function(){
	centerSocket.write(Packet.CreateNamePacket("gate"));
});
centerSocket.readForever(function(_, packet){
	var msgId = packet.readUInt16BE(2);
	console.log("msgid", msgId);
	return;
	
	var socketId = packet.readUInt16BE(4);
	var socket = socketDict[socketId];
	socket.write(packet);
});

var server = new net.Server();
server.on("connection", __onServerAccept);
server.on("error", __onServerError);
server.listen(gate_port, gate_host);

function __onServerAccept(socket){
	socket.on("close", function(){
		socket.removeAllListeners();
		delete socketDict[socket.uid];
		//centerSocket.write("quit);
	});
	//centerSocket.write("connect);
	socket.readForever(forwardClientPacket);

	socket.uid = nextSocketId;
	socketDict[nextSocketId] = socket;
	++nextSocketId;
}

function forwardClientPacket(socket, packet){
	packet.writeUInt16BE(socket.uid, 4);
	centerSocket.write(packet);
}

function __onServerError(err){
	switch(err.code){
		case "EADDRINUSE":
			console.error('Address in use, retrying...');
			break;
		default:
			console.error("socket server error!", err);
	}
}

