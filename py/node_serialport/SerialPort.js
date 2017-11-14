


class SerialPort
{
	static list(){
		return new Promise(resolve => {
			chrome.serial.getDevices(ports => {
				resolve(ports
					.filter(port => /^USB/.test(port.displayName))
					.map(port => port.path)
				);
			});
		});
	}

	constructor(path, options, callback){
		super();
		this.onData = this.onData.bind(this);
		this.connectionId = -1;
		chrome.serial.connect(path, options, info => {
			this.connectionId = info.connectionId;
			callback.call(this);
		});
		chrome.serial.onReceive.addListener(this.onData);
	}

	onData(info){
		if(info.connectionId != this.connectionId){
			return;
		}
		info.data
	}

	write(data){
		if(this.connectionId < 0)
			return;
		chrome.serial.send(this.connectionId, data, ()=>{});
	}

	close(){
		chrome.serial.disconnect(this.connectionId, () => {
			this.emit("close");
		});
	}
}