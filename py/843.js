"use strict";

const serverPort = require("./node_configs/serverPort");
require("Socket");

const text = '<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>';
const packet = new Buffer(text);

require("net").createServer(socket => {
	socket.on("data", chunk => {
		socket.write(packet, "utf8", () => {
			socket.end();
			socket.removeAllListeners();
		});
	});
	socket.listenCloseEvent(10000, null);
}).listen(843, serverPort.gate_host);