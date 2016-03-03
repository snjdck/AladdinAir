"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const SocketDict = require("SocketDict");
const socketDict = new SocketDict();

function onClientClose(socket){
	centerSocket.write(Packet.CreateClientClosePacket(socket.uid));
	socketDict.remove(socket);
}
function forwardClientPacket(socket, packet){
	packet.writeUInt16BE(socket.uid, 4);
	centerSocket.write(packet);
}
const server = net.createServer(function(socket){
	socketDict.add(socket);
	centerSocket.write(Packet.CreateClientConnectPacket(socket.uid));
	socket.readForever(forwardClientPacket);
	socket.listenCloseEvent(90000, onClientClose);
});
const centerSocket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	centerSocket.write(Packet.CreateNamePacket(serviceName));
	server.listen(serverPort.gate_port, serverPort.gate_host);
});
centerSocket.readForever(function(_, packet){
	var msgId = packet.readUInt16BE(2);
	var socketId = packet.readUInt16BE(4);
	socketDict.send(socketId, packet);
});