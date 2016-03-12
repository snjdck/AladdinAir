"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const nameDict = require("./node_configs/config").nameDict;
const net = require("net");
const Packet = require("Packet");
require("Socket");
const SocketDict = require("SocketDict");
const socketDict = new SocketDict();

function onClientClose(socket){
	centerSocket.sendPacketByName("client_disconnect", socket.uid);
	socketDict.remove(socket);
}
function forwardClientPacket(packet){
	packet.writeUInt16BE(this.uid, 4);
	centerSocket.write(packet);
}
const server = net.createServer(function(socket){
	socketDict.add(socket);
	centerSocket.sendPacketByName("client_connect", socket.uid);
	socket.readForever(forwardClientPacket);
	socket.listenCloseEvent(90000, onClientClose);
});
const centerSocket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	centerSocket.write(Packet.CreateNamePacket(serviceName));
	server.listen(serverPort.gate_port, serverPort.gate_host);
});
centerSocket.readForever(packet => {
	var msgId = packet.readUInt16BE(2);
	var usrId = packet.readUInt16BE(4);
	var socket = socketDict.findById(usrId);
	if(socket == null)
		return;
	switch(msgId){
		case nameDict["force_client_off"]:
			socket.destroy();
			break;
		default:
			packet.writeUInt16BE(0, 4);
			socket.write(packet);
	}
});