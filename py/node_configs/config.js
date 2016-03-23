"use strict";

const assert = require("assert");
const basename = require("path").basename;
const net = require("net");
require("Socket");
const PacketDispatcher = require("PacketDispatcher");
const Packet = require("Packet");
const serverPort = require("./serverPort");
const serverNameDict = require("./serverId").nameDict;
const config = require("./protocol");

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

function getSvrName(module){
	return basename(module.filename, ".js");
}

exports.connectCenterServer = function(module){
	var dispatcher = new PacketDispatcher();
	registerHandlers(dispatcher, module);
	var socket = net.connect(serverPort.center_port, serverPort.center_host, function(){
		socket.write(Packet.CreateNamePacket(getSvrName(module)));
		socket.readForever(dispatcher.dispatch.bind(dispatcher));
	});
	global.createPacket = socket.createPacket.bind(socket);
}

function registerHandlers(dispatcher, module){
	var svrName = getSvrName(module);
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

net.Socket.prototype.sendPacket = function(msgId, usrId, svrId, msgData){
	this.write(Packet.CreatePacket(castMsgId(msgId), usrId, castSvrId(svrId), msgData));
};