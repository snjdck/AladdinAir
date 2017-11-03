
const SerialPort = require("serialport");

function handleDataEvt(target, handler){
	var buffer = "";
	target.on("data", data => {
		buffer += data.toString("utf8").replace("\x00", "");
		var lines = buffer.split("\n");
		while(lines.length > 1){
			handler(lines.shift().trim());
		}
		buffer = lines[0];
	});
}

process.stdin.on("close", () => {
	process.exit();
});

handleDataEvt(process.stdin, data => {
	data = JSON.parse(data);
	switch(data.id){
	case "query_list":
		queryPortList();
		break;
	case "connect":
		connect_port(data.key);
		break;
	case "disconnect":
		disconnect_port();
		break;
	case "data":
		send_msg(data.key);
		break;
	}
});

function reply(id, key){
	var info = (key != null) ? {id, key} : {id};
	console.log(JSON.stringify(info));
}

async function queryPortList(){
	var list = await SerialPort.list();
	list = list.map(item => item.comName);
	reply("query_list", list);
}

var port;

function connect_port(name){
	disconnect_port();
	port = new SerialPort(name, {baudRate: 115200}, error => {
		reply("connect", error == null);
	});
	port.on("close", () => {
		reply("disconnect");
	});
	handleDataEvt(port, data => {
		reply("data", data);
	});
}

function disconnect_port(){
	if(port && port.isOpen){
		port.close();
		port = null;
	}
}

function send_msg(msg){
	if(port && port.isOpen){
		port.write(msg);
	}
}