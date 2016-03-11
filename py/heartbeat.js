"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const nameDict = require("./node_configs/config").nameDict;
const net = require("net");
const Packet = require("Packet");

const centerSocket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	centerSocket.write(Packet.CreateNamePacket(serviceName));
	var packet = Packet.CreatePacket(nameDict["heartbeat"]);
	setInterval(function(){
		centerSocket.write(packet);
	}, 1000);
});