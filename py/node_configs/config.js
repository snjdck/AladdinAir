"use strict";

const Socket = require("net").Socket;
const Packet = require("Packet");
const serverNameDict = require("./serverId").nameDict;
const assert = require("assert");

Socket.prototype.sendPacketByName = function(msgName, usrId, svrName, msgData){
	assert(msgName in nameDict,	`msgName "${msgName}" not exist!`);
	var svrId;
	if(typeof svrName == "string"){
		assert(svrName in serverNameDict, `serverName "${svrName}" not exist!`);
		svrId = serverNameDict[svrName];
	}else{
		svrId = svrName;
	}
	
	this.sendPacket(nameDict[msgName], usrId, svrId, msgData);
};

const config = require("./protocol");

const handlerDict = [];
const notifyDict = [];
const idDict = [];
const nameDict = {};
const clientMsgIdList = [];

for(var key in config){
	var info = config[key];
	if(info == null)
		continue;
	var id = info.id;
	idDict[id] = key;
	nameDict[key] = id;
	if(info.type == "c2s"){
		clientMsgIdList[id] = serverNameDict[info.dest];
	}
	notifyDict[id] = [info.dest];
	if(info.handler != null)
		handlerDict[id] = info.handler;
}

exports.handlerDict = handlerDict;
exports.notifyDict = notifyDict;
exports.idDict = idDict;
exports.nameDict = nameDict;
exports.clientMsgIdList = clientMsgIdList;