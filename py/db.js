"use strict";

const config = require("./node_configs/config");
const serverPort = require("./node_configs/serverPort");
const MongoClient = require("mongodb").MongoClient;
const assert = require("assert");

MongoClient.connect(serverPort.db_url, function(err, db){
	assert.equal(null, err);
	config.connectCenterServer(module);
	global.db = db;
});
