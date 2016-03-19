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

function onRegister(usrId, msgData){
	socket.sendPacketByName("client_register_reply", usrId, {result:true});
}

function onLogin(usrId, msgData){
	if(false){
		socket.sendPacketByName("client_login_notify", usrId);
	}else{
		socket.sendPacketByName("client_login_reply", usrId, {result:false});
	}
}

function onCheckNameValid(usrId, msgData){
	socket.sendPacketByName("client_check_name_valid_reply", usrId, {result:true});
}
