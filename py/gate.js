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
	Packet.WriteUsrId(packet, this.uid);
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
	var msgId = Packet.ReadMsgId(packet);
	var usrId = Packet.ReadUsrId(packet);
	var socket = socketDict.findById(usrId);
	if(socket == null)
		return;
	switch(msgId){
		case nameDict["force_client_off"]:
			socket.destroy();
			break;
		default:
			Packet.WriteUsrId(packet, 0);
			socket.write(packet);
	}
});