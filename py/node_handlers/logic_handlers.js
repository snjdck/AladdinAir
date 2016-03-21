"use strict";

exports.onHeartBeart = function(packet){
	console.log("heart beat");
};

exports.onClientConnect = function(packet){
	console.log("connect");
	console.log(JSON.stringify(packet));
};

exports.onClientDisconnect = function(packet){
	console.log("disconnect");
};

exports.onClientLogin = function(packet){
	console.log("login");
};

exports.onTest = function(packet){
	global.socket.sendPacketByName("test1_reply", packet.usrId, packet.svrId);
	/*
	setTimeout(() => {
		this.write(Packet.CreatePacket(nameDict["force_client_off"], usrId));
	}, 2000);
*/
};

exports.onTest2 = function(packet){
	/*
	var packet = new Buffer(6);
	packet.writeUInt16BE(packet.length);
	packet.writeUInt16BE(102, 2);
	packet.writeUInt16BE(usrId, 4);
	this.write(packet);
	*/
};