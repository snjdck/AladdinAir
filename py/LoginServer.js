"use strict";

const serviceName = require("path").basename(__filename, ".js");
const serverPort = require("./node_configs/serverPort");
const config = require("./node_configs/config");
const net = require("net");
const web = require("web");
const Packet = require("Packet");

const centerSocket = net.connect(serverPort.center_port, serverPort.center_host, function(){
	centerSocket.write(Packet.CreateNamePacket("login"));
});

const http = require("http");
const path = require("path");
const url = require("url");

web.createServer(function(request, response, body){
	var params = url.parse(request.url, true);
	console.log(params.pathname);
}).listen(8080);