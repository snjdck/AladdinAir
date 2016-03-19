"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const net = require("net");
const Packet = require("Packet");
require("Socket");
const nameDict = require("./node_configs/config").nameDict;
const PacketDispatcher = require("PacketDispatcher");

const dispatcher = new PacketDispatcher();

const socket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	socket.write(Packet.CreateNamePacket(serviceName));
	socket.readForever(dispatcher.dispatch.bind(dispatcher));
});


dispatcher.addHandler(nameDict["client_register"],			onRegister);
dispatcher.addHandler(nameDict["client_login"],				onLogin);
dispatcher.addHandler(nameDict["client_check_name_valid"],	onCheckNameValid);

function onRegister(packet){
	socket.sendPacketByName("client_register_reply", packet.usrId, {result:true});
}

function onLogin(packet){
	if(false){
		socket.sendPacketByName("client_login_notify", packet.usrId);
	}else{
		socket.sendPacketByName("client_login_reply", packet.usrId, {result:false});
	}
}

function onCheckNameValid(packet){
	socket.sendPacketByName("client_check_name_valid_reply", packet.usrId, {result:true});
}
