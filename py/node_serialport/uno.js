"use strict";

const SerialPort = require("./SerialPort");
const fs = require("fs");

function sleep(seconds){
	return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

function waitResponse(target, bytesWait){
	return new Promise((resolve, reject) => {
		let buffer = Buffer.alloc(0);
		target.on("data", data => {
			buffer = Buffer.concat([buffer, data]);
			if(buffer.length < bytesWait + 2){
				return;
			}
			if(buffer[0] != 0x14 || buffer[bytesWait+1] != 0x10){
				target.close();
				reject();
			}else{
				target.removeAllListeners();
				resolve(buffer.slice(1, 1+bytesWait));
			}
		});
	});
}

async function send(target, data, bytesWait=0){
	target.write(data);
	return await waitResponse(target, bytesWait);
}

function upload(port, payload, uploadProgress=emptyFn, verifyProgress=emptyFn){
	return new Promise((resolve, reject) => {
		new SerialPort(port, {bitrate: 115200}, async function(error){
			if(error != null){
				reject(error);
				return;
			}
			await sleep(0.1);
			await send(this, Buffer.from([0x30, 0x20]));
			await send(this, Buffer.from([0x50, 0x20]));
			await writeData(this, payload, uploadProgress);
			let verify = await readData(this, payload, verifyProgress);
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
const emptyFn = ()=>{};

async function writeData(target, payload, onProgress){
	const total = payload.length;
	let address = 0;
	while(address < total){
		onProgress(address / total);
		let bytesSend = Math.min(0x80, total - address);
		addressInfo[1] = (address >> 1) & 0xFF;
		addressInfo[2] = (address >> 9);
		await send(target, addressInfo);
		await send(target, Buffer.concat([
			Buffer.from([0x64, 0x00, bytesSend, 0x46]),
			payload.slice(address, address + bytesSend),
			Buffer.from([0x20])
		]));
		address += bytesSend;
	}
	onProgress(1);
}

async function readData(target, payload, onProgress){
	let buffer = Buffer.alloc(0);
	const total = payload.length;
	let address = 0;
	while(address < total){
		onProgress(address / total);
		let bytesSend = 0x80;
		addressInfo[1] = (address >> 1) & 0xFF;
		addressInfo[2] = (address >> 9);
		await send(target, addressInfo);
		let data = await send(target, Buffer.from([0x74, 0x00, bytesSend, 0x46, 0x20]), bytesSend);
		address += bytesSend;
		buffer = Buffer.concat([buffer, data]);
	}
	onProgress(1);
	return payload.compare(buffer, 0, total);
}

function uploadHex(port, data, uploadProgress, verifyProgress){
	return upload(port, Buffer.from(data.trim()
		.split(/\s+/)
		.map(line => line.slice(9, -2))
		.join("")
		.match(/\w{2}/g)
		.map(item => parseInt(item, 16))
	), uploadProgress, verifyProgress);
}

function uploadFile(port, file, uploadProgress, verifyProgress){
	return uploadHex(port, fs.readFileSync(file, "ascii"), uploadProgress, verifyProgress);
}

//[Colon] [Data Size] [Start Address] [Record Type] [Data] [Checksum]
//[:][10][0000][00][0C9434000C944F000C944F000C944F00][4F]

module.exports = {uploadHex, uploadFile};
