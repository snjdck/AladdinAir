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
	socket.createPacket("client_register_reply", {result:true}).forward(packet);
}

function onLogin(packet){
	if(false){
		socket.createPacket("client_login_notify").sendTo("logic", packet.usrId);
	}else{
		socket.createPacket("client_login_reply", {result:true}).forward(packet);
	}
}

function onCheckNameValid(packet){
	socket.createPacket("client_check_name_valid_reply", {result:true}).forward(packet);
}
