"use strict";

const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");

const socket = net.connect(serverPort.gate_port, serverPort.gate_host, function(){
	socket.readForever((_, packet) => {
		console.log(packet);
	});
	var packet = Packet.CreatePacket(101, 0);
	setInterval(function(){
		socket.write(packet);
	}, 1000);
});