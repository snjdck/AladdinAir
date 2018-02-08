"use strict";

const SerialPort = require("./SerialPort");

function sleep(seconds){
	return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

function waitResponse(target, bytesWait=0){
	return new Promise((resolve, reject) => {
		let bufferList = [];
		let bufferSize = 0;
		target.on("data", data => {
			bufferList.push(data);
			bufferSize += data.length;
			if(bufferSize < bytesWait + 2){
				return;
			}
			let buffer = Buffer.concat(bufferList, bufferSize);
			if(buffer[0] != 0x14 || buffer[bytesWait+1] != 0x10){
				target.close();
				reject();
			}else{
				target.removeAllListeners();
				if(bytesWait > 0){
					resolve(buffer.slice(1, 1+bytesWait));
				}else{
					resolve();
				}
			}
		});
	});
}

async function send(target, data, bytesWait=0){
	target.write(data);
	return await waitResponse(target, bytesWait);
}

function upload(port, payload, onProgress=()=>{}){
	return new Promise((resolve, reject) => {
		new SerialPort(port, {bitrate: 115200}, async function(error){
			if(error != null){
				reject(error);
				return;
			}
			await sleep(0.1);
			await send(this, Buffer.from([0x30, 0x20]));
			await send(this, Buffer.from([0x50, 0x20]));
			await writeData(this, payload, v => onProgress(v * 0.5));
			let verify = await readData(this, payload, v => onProgress(v * 0.5 + 0.5));
			await send(this, Buffer.from([0x51, 0x20]));

			this.close();

			if(verify == 0){
				resolve();
			}else{
				reject("verify failed!");
			}
		});
	});
}

const addressInfo = Buffer.from([0x55, 0, 0, 0x20]);
const requestSend =[Buffer.from([0x64, 0x00, 0, 0x46]), null, Buffer.from([0x20])];
const requestRecv = Buffer.from([0x74, 0x00, 0, 0x46, 0x20]);

async function writeData(target, payload, onProgress){
	const total = payload.length;
	let address = 0;
	while(address < total){
		onProgress(address / total);
		let bytesSend = Math.min(0x80, total - address);
		addressInfo[1] = (address >> 1) & 0xFF;
		addressInfo[2] = (address >> 9);
		requestSend[0][2] = bytesSend;
		requestSend[1] = payload.slice(address, address + bytesSend);
		await send(target, addressInfo);
		await send(target, Buffer.concat(requestSend));
		address += bytesSend;
	}
}

async function readData(target, payload, onProgress){
	let bufferList = [];
	const total = payload.length;
	let address = 0;
	while(address < total){
		onProgress(address / total);
		let bytesSend = Math.min(0x80, total - address);
		addressInfo[1] = (address >> 1) & 0xFF;
		addressInfo[2] = (address >> 9);
		requestRecv[2] = bytesSend;
		await send(target, addressInfo);
		bufferList.push(await send(target, requestRecv, bytesSend));
		address += bytesSend;
	}
	return payload.compare(Buffer.concat(bufferList));
}

function uploadHex(port, data, onProgress){
	return upload(port, Buffer.from(data.trim()
		.split(/\s+/)
		.map(line => line.slice(9, -2))
		.join("")
		.match(/\w{2}/g)
		.map(item => parseInt(item, 16))
	), onProgress);
}

function uploadFile(port, file, onProgress){
	let fs = require("fs");
	return uploadHex(port, fs.readFileSync(file, "ascii"), onProgress);
}

//[Colon] [Data Size] [Start Address] [Record Type] [Data] [Checksum]
//[:][10][0000][00][0C9434000C944F000C944F000C944F00][4F]

module.exports = {uploadHex, uploadFile};
