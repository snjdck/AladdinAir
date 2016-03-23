"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const config = require("./node_configs/config");
const PacketDispatcher = require("PacketDispatcher");
const ClientMgr = require("ClientMgr");

const dispatcher = new PacketDispatcher();
config.registerHandlers(dispatcher, module);

const socket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	socket.write(Packet.CreateNamePacket(serviceName));
	socket.readForever(dispatcher.dispatch.bind(dispatcher));
});

global.clientMgr = new ClientMgr();
global.createPacket = socket.createPacket.bind(socket);
