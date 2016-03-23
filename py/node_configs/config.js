"use strict";

const basename = require("path").basename;
const serverNameDict = require("./serverId").nameDict;
const config = require("./protocol");
const Socket = require("net").Socket;
const Packet = require("Packet");
const assert = require("assert");

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
}

exports.notifyDict = notifyDict;
exports.idDict = idDict;
exports.nameDict = nameDict;
exports.clientMsgIdList = clientMsgIdList;

exports.registerHandlers = function(dispatcher, module){
	var svrName = basename(module.filename, ".js");
	for(var key in config){
		var info = config[key];
		if(info == null || info.dest != svrName)
			continue;
		var path = info.handler;
		var index = path.lastIndexOf(".");
		var handler = module.require(path.slice(0, index))[path.slice(index+1)];
		dispatcher.addHandler(info.id, handler);
	}
}


function castMsgId(msgId){
	if(typeof msgId == "string"){
		assert(msgId in nameDict, `msgName "${msgId}" not exist!`);
		msgId = nameDict[msgId];
	}
	return msgId;
}

function castSvrId(svrId){
	if(typeof svrId == "string"){
		assert(svrId in serverNameDict, `serverName "${svrId}" not exist!`);
		svrId = serverNameDict[svrId];
	}
	return svrId;
}

Socket.prototype.sendPacket = function(msgId, usrId, svrId, msgData){
	this.write(Packet.CreatePacket(castMsgId(msgId), usrId, castSvrId(svrId), msgData));
};