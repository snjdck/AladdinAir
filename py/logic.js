"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const handlerDict = require("./node_configs/config").handlerDict;
const PacketDispatcher = require("PacketDispatcher");
const ClientMgr = require("ClientMgr");

const dispatcher = new PacketDispatcher();

const socket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	socket.write(Packet.CreateNamePacket(serviceName));
	socket.readForever(dispatcher.dispatch.bind(dispatcher));
	for(var msgId in handlerDict){
		var path = handlerDict[msgId];
		var index = path.lastIndexOf(".");
		var handler = require(path.slice(0, index))[path.slice(index+1)];
		dispatcher.addHandler(parseInt(msgId), handler);
	}
});
global.clientMgr = new ClientMgr();
global.socket = socket;
