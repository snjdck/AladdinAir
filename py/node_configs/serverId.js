"use strict";

const idDict = [];
const nameDict = {
	heartbeat	: 1,
	logic		: 2,
	login		: 3,
	db			: 4,
	gate		: 5
};

for(var name in nameDict){
	idDict[nameDict[name]] = name;
}

exports.idDict = idDict;
exports.nameDict = nameDict;