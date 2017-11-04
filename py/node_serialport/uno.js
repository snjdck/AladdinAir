const SerialPort = require("serialport");
const fs = require("fs");

function sleep(seconds){
	return new Promise(resolve => setTimeout(resolve, seconds * 1000));
}

function waitResponse(target){
	return new Promise((resolve, reject) => {
		var buffer = Buffer.alloc(0);
		target.on("data", data => {
			buffer = Buffer.concat([buffer, data]);
			if(buffer.length < 2){
				return;
			}
			if(buffer[0] != 0x14 || buffer[1] != 0x10){
				target.close();
				reject();
			}else{
				target.removeAllListeners();
				resolve();
			}
		});
	});
}

async function send(target, data){
	target.write(data);
	await waitResponse(target);
}

function upload(port, payload){
	return new Promise((resolve, reject) => {
		new SerialPort(port, {baudRate: 115200}, async function(error){
			if(error != null){
				reject(error);
				return;
			}
			await sleep(0.1);
			await send(this, Buffer.from([0x30, 0x20]));
			await send(this, Buffer.from([0x50, 0x20]));

			var address = 0;
			var addressInfo = Buffer.from([0x55, 0, 0, 0x20]);

			while(address < payload.length){
				var bytesSend = Math.min(0x80, payload.length - address);
				addressInfo[1] = (address >> 1) & 0xFF;
				addressInfo[2] = (address >> 9);
				await send(this, addressInfo);
				await send(this, Buffer.concat([
					Buffer.from([0x64, 0x00, bytesSend, 0x46]),
					payload.slice(address, address + bytesSend),
					Buffer.from([0x20])
				]));
				address += bytesSend;
			}

			await send(this, Buffer.from([0x51, 0x20]));

			this.close();
			resolve();
		});
	});
}

function uploadHex(port, payload){
	payload = payload.trim().split(/\s+/).map(line => {
		var size = parseInt(line.substr(1, 2), 16);
		return line.substr(9, 2 * size);
	}).join("").match(/\w{2}/g).map(item => parseInt(item, 16));
	return upload(port, Buffer.from(payload));
}

function uploadFile(port, file){
	return uploadHex(port, fs.readFileSync(file, "ascii"));
}

//[Colon] [Data Size] [Start Address] [Record Type] [Data] [Checksum]
//[:][10][0000][00][0C9434000C944F000C944F000C944F00][4F]

module.exports = {uploadHex, uploadFile};
