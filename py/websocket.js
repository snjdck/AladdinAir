"use strict";

const EventEmitter = require('events');
const http = require("http");
const crypto = require('crypto');

const mask = new Array(4);

class WebSocketClient extends EventEmitter
{
	constructor(socket){
		super();
		this.socket = socket;
		handleSockRecv.call(this);
	}

	write(data){
		this.socket.write(createPacket(data));
	}
}

class WebSocketServer extends EventEmitter
{
	constructor(){
		super();
		this.server = new http.Server();
		this.server.on("upgrade", onUpgrade.bind(this));
	}

	listen(port, host){
		this.server.listen(port, host || "127.0.0.1");
	}
}

function onUpgrade(request, socket, head){
	console.log(request.url, request.headers);
	if(request.method != "GET"){
		return;
	}
	const headers = request.headers;
	if(headers.connection != "Upgrade" || headers.upgrade != "websocket"){
		return;
	}
	var key = headers["sec-websocket-key"] + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
	key = crypto.createHash('sha1').update(key).digest("base64");

	var responseText = "HTTP/1.1 101 Switching Protocols\r\n";
	responseText += "connection: Upgrade\r\n";
	responseText += "upgrade: websocket\r\n";
	responseText += `sec-websocket-accept: ${key}\r\n`;
	responseText += "\r\n";

	socket.write(responseText);
	this.emit("connection", new WebSocketClient(socket));
}

function handleSockRecv(){
	var buffer = new Buffer(0);
	var begin = 0;
	this.socket.on("data", chunk => {
		console.log(chunk);
		const end = buffer.length + chunk.length;
		buffer = Buffer.concat([buffer, chunk], end);
		for(;;){
			if(end - begin < 2)
				break;
			const byte1 = buffer.readUInt8(begin);
			const byte2 = buffer.readUInt8(begin+1);

			const finFlag	= byte1 >> 7 == 1;
			const opCode	= byte1 & 0xF;
			const hasMask	= byte2 >> 7 == 1;
			var payloadLen	= byte2 & 0x7F;

			const headLen = calcHeadLen(hasMask, payloadLen);
			if(end - begin < headLen)
				break;
			payloadLen = readPayloadLen(buffer, payloadLen, begin);
			if(end - begin < headLen + payloadLen)
				break;
			begin += headLen;

			if(hasMask){
				readMask(buffer, begin - 4);
				decodePayload(buffer, begin, payloadLen);
			}
			parsePayload.call(this, opCode, buffer, begin, payloadLen);
			begin += payloadLen;
		}
		if(begin > 0){
			buffer = buffer.slice(begin);
			begin = 0;
		}
	});
}

function parsePayload(opCode, buffer, begin, payloadLen){
	switch(opCode){
		case 0:
			break;
		case 1://text
			var payload = buffer.toString("utf8", begin, begin+payloadLen);
			this.emit("data", payload);
			break;
		case 2://binary
			var payload = buffer.slice(begin, begin+payloadLen);
			this.emit("data", payload);
			break;
		case 8://close
			this.emit("close", buffer.readUInt16BE(begin));
			break;
		case 9://ping
			break;
		case 10://pong
			break;
		default:
			break;
	}
	
}

function readMask(packet, offset){
	for(var i=0; i<4; ++i){
		mask[i] = packet.readUInt8(offset+i);
	}
}

function decodePayload(packet, offset, payloadLen){
	for(var i=0; i<payloadLen; ++i){
		var index = offset + i;
		var value = packet.readUInt8(index);
		value ^= mask[i % 4];
		packet.writeUInt8(value, index);
	}
}

function calcHeadLen(hasMask, payloadLen){
	var headLen;
	if(payloadLen < 126)
		headLen = 2;
	else if(payloadLen == 126)
		headLen = 4;
	else
		headLen = 10;
	if(hasMask)
		headLen += 4;
	return headLen;
}

function calcPacketLen(payloadLen, hasMask){
	var packetLen;
	if(payloadLen < 126)
		packetLen = 2 + payloadLen;
	else if(payloadLen < 0x10000)
		packetLen = 4 + payloadLen;
	else
		packetLen = 10 + payloadLen;
	if(hasMask)
		packetLen += 4;
	return packetLen;
}

function readPayloadLen(packet, payloadLen, offset){
	if(payloadLen <  126)	return payloadLen;
	if(payloadLen == 126)	return packet.readUInt16BE(offset+2);
	return packet.readUInt32BE(offset+6);
}

function writePayloadLen(packet, payloadLen){
	if(payloadLen < 126){
		packet.writeUInt8(payloadLen, 1);
	}else if(payloadLen < 0x10000){
		packet.writeUInt8(126, 1);
		packet.writeUInt16BE(payloadLen, 2);
	}else{
		packet.writeUInt8(127, 1);
		packet.writeUInt32BE(0, 2);
		packet.writeUInt32BE(payloadLen, 6);
	}
}

function createPacket(data){
	const isBuffer = Buffer.isBuffer(data);
	var opCode, payloadLen;
	if(isBuffer){
		opCode = 2;
		payloadLen = data.length;
	}else{
		opCode = 1;
		payloadLen = Buffer.byteLength(data);
	}
	const packetLen = calcPacketLen(payloadLen);
	const packet = new Buffer(packetLen);
	packet.writeUInt8(0x80 | opCode, 0);
	writePayloadLen(packet, payloadLen);
	if(isBuffer){
		data.copy(packet, packetLen - payloadLen);
	}else{
		packet.write(data, packetLen - payloadLen);
	}
	return packet;
}

module.exports = {WebSocketServer, WebSocketClient};