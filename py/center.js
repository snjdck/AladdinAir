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
	if(socketList.indexOf(this) < 0){
		this.setTimeout(0);
		var name = packet.toString("utf8", 2);
		this.id = nameDict[name];
		console.log(`${name}\t\t${this.id}`);
		assert(this.id > 0 && socketList[this.id] == null);
		socketList[this.id] = this;
		return;
	}
	var svrId = Packet.ReadSvrId(packet);
	var socket = socketList[svrId];
	if(socket != null){
		Packet.WriteSvrId(packet, this.id);
		socket.write(packet);
	}else{
		console.log(this.id, "dispatch failed!");
	}
}