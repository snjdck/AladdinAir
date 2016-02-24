"use strict"

var gate_host = "127.0.0.1";
var gate_port = 7411;

var center_host = "127.0.0.1";
var center_port = 7410;

var net = require("net");

function handleRecvData(socket, handler){
	var recvBuffer = new Buffer(0);
	var begin = 0;
	socket.on("data", function(chunk){
		recvBuffer = Buffer.concat([recvBuffer, chunk]);
		var end = recvBuffer.length;
		for(;;){
			if(end - begin < 2)
				break;
			var packetLen = recvBuffer.readUInt16BE(begin);
			if(end - begin < packetLen)
				break;
			handler(socket, recvBuffer.slice(begin, begin+packetLen));
			begin += packetLen;
		}
		if(begin > 0){
			recvBuffer = recvBuffer.slice(begin);
			begin = 0;
		}
	});
}

var socketDict = {};
var nextSocketId = 0;

var centerSocket = new net.Socket();
centerSocket.on("connect", function(){
	var name = "gate";
	var packet = new Buffer(name.length + 2);
	packet.writeUInt16BE(name.length + 2);
	packet.write(name, 2);
	centerSocket.write(packet);
});
handleRecvData(centerSocket, function(_, packet){
	var msgId = packet.readUInt16BE(2);
	console.log("msgid", msgId);
	return;
	
	var socketId = packet.readUInt16BE(4);
	var socket = socketDict[socketId];
	socket.write(packet);
});
centerSocket.connect(center_port, center_host);


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
	handleRecvData(socket, forwardClientPacket);

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

