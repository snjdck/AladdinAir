"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const handlerDict = require("./node_configs/handlerDict");
const PacketDispatcher = require("PacketDispatcher");

const dispatcher = new PacketDispatcher();

const centerSocket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	centerSocket.write(Packet.CreateNamePacket(serviceName));
	centerSocket.readForever(dispatcher.dispatch.bind(dispatcher));
	for(var msgId in handlerDict){
		var list = handlerDict[msgId].split(".");
		var handler = require("./node_handlers/"+list[0])[list[1]];
		if(null == handler){
			console.error("handler not set:" + msgId);
			continue;
		}
		dispatcher.addHandler(parseInt(msgId), handler.bind(centerSocket));
	}
});