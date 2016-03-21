"use strict";

const Socket = require("net").Socket;
const assert = require("assert");

const idDict = [];
const nameDict = {
	heartbeat	: 1,
	logic		: 2,
	login		: 3,
	db			: 4,
	gate		: 5
};

for(var name in nameDict){
	let id = nameDict[name];
	idDict[id] = name;
	Socket.prototype[`send_to_${name}`] = function(msgName, usrId, msgData){
		this.sendPacketByName(msgName, usrId, id, msgData);
	};
}

exports.idDict = idDict;
exports.nameDict = nameDict;