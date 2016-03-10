"use strict";

exports.onHeartBeart = function(usrId, msgData){
	console.log("heart beat");
};

exports.onClientConnect = function(usrId, msgData){
	console.log("connect");
};

exports.onClientDisconnect = function(usrId, msgData){
	console.log("disconnect");
};

exports.onTest = function(usrId, msgData){
	var packet = new Buffer(6);
	packet.writeUInt16BE(packet.length);
	packet.writeUInt16BE(102, 2);
	packet.writeUInt16BE(usrId, 4);
	this.write(packet);
};

exports.onTest2 = function(usrId, msgData){
	/*
	var packet = new Buffer(6);
	packet.writeUInt16BE(packet.length);
	packet.writeUInt16BE(102, 2);
	packet.writeUInt16BE(usrId, 4);
	this.write(packet);
	*/
};