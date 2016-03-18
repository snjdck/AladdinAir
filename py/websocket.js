"use strict";

const http = require("http");
const crypto = require('crypto');

const server = new http.Server();
server.listen(8081, "127.0.0.1");

server.on("upgrade", function(request, socket, head){
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
	handleSockRecv(socket);
});

function handleSockRecv(socket){
	const mask = new Array(4);
	var buffer = new Buffer(0);
	var begin = 0;
	socket.on("data", function(chunk){
		console.log(chunk);
		const end = buffer.length + chunk.length;
		buffer = Buffer.concat([buffer, chunk], end);
		for(;;){
			var offset = 2;
			if(end - begin < offset)
				break;
			const byte1 = buffer.readUInt8(begin);
			const byte2 = buffer.readUInt8(begin+1);

			const finFlag	= byte1 >> 7 == 1;
			const opCode	= byte1 & 0x7F;
			const hasMask	= byte2 >> 7 == 1;
			var payloadLen	= byte2 & 0x7F;
			
			if(payloadLen == 126){
				offset += 2;
				if(end - begin < offset)
					break;
				payloadLen = buffer.readUInt16BE(begin+2);
			}else if(payloadLen == 127){
				offset += 8;
				if(end - begin < offset)
					break;
				payloadLen = (buffer.readUInt32BE(begin+2) << 32) | buffer.readUInt32BE(begin+6);
			}
			if(hasMask){
				if(end - begin < offset + 4 + payloadLen)
					break;
				begin += offset;
				for(var i=0; i<4; ++i)
					mask[i] = buffer.readUInt8(begin++);
				for(var i=0; i<payloadLen; ++i){
					var index = begin + i;
					buffer.writeUInt8(buffer.readUInt8(index) ^ mask[i % 4], index);
				}
			}else{
				if(end - begin < offset + payloadLen)
					break;
				begin += offset;
			}
			parsePayload(socket, opCode, buffer, begin, payloadLen);
			begin += payloadLen;
		}
		if(begin > 0){
			buffer = buffer.slice(begin);
			begin = 0;
		}
	});
}

function parsePayload(socket, opCode, buffer, begin, payloadLen){
	var payload = null;
	switch(opCode){
		case 1://text
			payload = buffer.toString("utf8", begin, begin+payloadLen);
			break;
		case 2://binary
			payload = buffer.slice(begin, begin+payloadLen);
			break;
		case 8://close
			console.log("close reason:", buffer.readUInt16BE(begin));
			break;
	}
	console.log(payload);
}
