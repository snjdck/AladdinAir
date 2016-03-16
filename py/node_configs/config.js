"use strict";

const Socket = require("net").Socket;
const Packet = require("Packet");

Socket.prototype.sendPacketByName = function(msgName, usrId, msgData){
	if(msgName in nameDict)
		this.sendPacket(nameDict[msgName], usrId, msgData);
	else
		console.error(`msgName "${msgName}" not exist!`);
};

const config = require("./protocol");

const handlerDict = [];
const notifyDict = [];
const idDict = [];
const nameDict = {};

for(var key in config){
	var info = config[key];
	if(info == null)
		continue;
	var id = info[0];
	idDict[id] = key;
	nameDict[key] = id;
	notifyDict[id] = info[1];
	if(info[2] != null)
		handlerDict[id] = info[2];
}

exports.handlerDict = handlerDict;
exports.notifyDict = notifyDict;
exports.idDict = idDict;
exports.nameDict = nameDict;