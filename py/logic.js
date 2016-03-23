"use strict";

const config = require("./node_configs/config");
const ClientMgr = require("ClientMgr");

config.connectCenterServer(module);
global.clientMgr = new ClientMgr();
