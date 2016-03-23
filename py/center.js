"use strict";

const serverPort = require("./node_configs/serverPort");
const nameDict = require("./node_configs/serverId").nameDict;
const Packet = require("Packet");
const assert = require('assert');
require("Socket");

require("net").createServer(socket => {
	socket.readForever(onRecvPacket);
	socket.listenCloseEvent(1000, onSocketClose);
}).listen(serverPort.center_port, serverPort.center_host);

const socketList = [];

function onSocketClose(socket){
	if(socketList.indexOf(socket) >= 0)
		socketList[socket.id] = null;
}

function onRecvPacket(packet){
	if(this.loginFlag){
		var svrId = Packet.ReadSvrId(packet);
		var socket = socketList[svrId];
		if(socket == null || socket == this){
			console.error(this.id, "dispatch failed!");
			return;
		}
		Packet.WriteSvrId(packet, this.id);
		socket.write(packet);
	}else{
		var name = packet.toString("utf8", 2);
		var id = nameDict[name];
		assert(id > 0 && socketList[id] == null);
		socketList[id] = this;
		this.setTimeout(0);
		this.id = id;
		this.loginFlag = true;
	}
}
