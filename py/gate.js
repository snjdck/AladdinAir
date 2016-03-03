"use strict";

const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const SocketDict = require("SocketDict");
const socketDict = new SocketDict();

const server = net.createServer(function(socket){
	socketDict.add(socket);
	centerSocket.write(Packet.CreateClientConnectPacket(socket.uid));
	socket.readForever(forwardClientPacket);
	function onClose(err){
		socket.removeAllListeners();
		centerSocket.write(Packet.CreateClientClosePacket(socket.uid));
		socketDict.remove(socket);
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
	socketDict.send(socketId, packet);
});
function forwardClientPacket(socket, packet){
	packet.writeUInt16BE(socket.uid, 4);
	centerSocket.write(packet);
}