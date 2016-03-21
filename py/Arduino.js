"use strict";

const SerialPort = require("serialport").SerialPort;
const WebSocketServer = require("./websocket").WebSocketServer;

const server = new WebSocketServer();
server.listen(8081);

server.on("connection", function(client){
	client.on("data", function(data){
		console.log(data);
		client.write("reply from server");
		serial.write(data);
	});
	client.on("close", function(code){
		console.log("client close,", code);
	});
});

var serial = new SerialPort("COM4", {
	baudrate: 115200
});
serial.on("open", function(){
	//setTimeout(sendData, 2000);
});

function sendData(){
	var buffer = new Buffer([ 0xff, 0x55 , 0x09 , 0x00 , 0x02 , 0x08 , 0x07 , 0x02 , 0x00 , 0x14 , 0x00 , 0x00]);
	serial.write(buffer);
	console.log("success");
}