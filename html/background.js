/**
 * Listens for the app launching, then creates the window.
 *
 * @see http://developer.chrome.com/apps/app.runtime.html
 * @see http://developer.chrome.com/apps/app.window.html
 */

function BufferData(){
  this.recvBuffer = new ArrayBuffer(0);
}
BufferData.prototype.getView = function(type){
  return new type(this.recvBuffer);
};
BufferData.prototype.appendData = function(bytes){
  this.recvBuffer = mergeArrayBuffer(this.recvBuffer, bytes);
};
BufferData.prototype.shiftData = function(count){
  this.recvBuffer = this.recvBuffer.slice(count);
};
BufferData.prototype.isEnough = function(size){
  return this.recvBuffer.byteLength >= size;
};
BufferData.prototype.getArrayBuffer = function(begin, end){
  return this.recvBuffer.slice(begin, end);
};
BufferData.prototype.getJSON = function(begin, end){
  return JSON.parse(this.getString(begin, end));
};
BufferData.prototype.getString = function(begin, end){
  return String.fromCharCode.apply(null,
    new Uint8Array(this.recvBuffer, begin, end - begin)
  );
};

function mergeArrayBuffer(buffer1, buffer2){
  var newBuffer = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
  newBuffer.set(new Uint8Array(buffer1), 0 );
  newBuffer.set(new Uint8Array(buffer2), buffer1.byteLength);
  return newBuffer.buffer;
}

function UnoUploader(data){
  this.recvBuffer = new BufferData();
  this.state = 0;
  this.address = 0;
  this.data = data;
  
  this.handshakeData = new Uint8Array([0x30, 0x20]).buffer;
  this.enterProgramData = new Uint8Array([0x50, 0x20]).buffer;
  this.leaveProgramData = new Uint8Array([0x51, 0x20]).buffer;
  this.setAddressData = new Uint8Array([0x55, 0, 0, 0x20]);
}
UnoUploader.prototype.send = function(bytes){
  serial.send(serialId, bytes, function(sendInfo){});
};
UnoUploader.prototype.handshake = function(){
  setTimeout(this.send, 100, this.handshakeData);
};
UnoUploader.prototype.onRecv = function(bytes){
  this.recvBuffer.appendData(bytes);
  this.check();
};
UnoUploader.prototype.check = function(){
  if(!this.recvBuffer.isEnough(2)){
    return;
  }
  var dataView = this.recvBuffer.getView(Uint8Array);
  if(dataView[0] != 0x14 || dataView[1] != 0x10){
    console.log("serial error", dataView);
    return;
  }
  this.recvBuffer.shiftData(2);
  this.update();
};
UnoUploader.prototype.update = function(){
  switch(this.state){
    case 0://wait to enter program mode
      this.send(this.enterProgramData);
      ++this.state;
      break;
    case 1://wait to send address
      this.setAddressData[1] = (this.address >> 1) & 0xFF;
      this.setAddressData[2] = this.address >> 9;
      this.send(this.setAddressData.buffer);
      ++this.state;
      break;
    case 2://wait to send data
      var sendSize = 0x80;
      if(this.address + sendSize >= this.data.byteLength){
        sendSize = this.data.byteLength - this.address;
        ++this.state;
      }else{
        --this.state;
      }
      var buffer = mergeArrayBuffer(
        new Uint8Array([0x64, 0x00, sendSize, 0x46]).buffer,
        mergeArrayBuffer(
          this.data.slice(this.address, this.address+sendSize),
          new Uint8Array([0x20]).buffer
        )
      );
      serial.send(serialId, buffer, function(sendInfo){
        console.log("sendInfo", sendInfo);
      });
      this.address += sendSize;
      break;
    case 3://wait to exit
      this.send(this.leaveProgramData);
      ++this.state;
      break;
    case 4://wait to leave
      serial.disconnect(serialId, function(success){
        console.log("upload finish");
      });
      break;
  }
};


var tcpServer       = chrome.sockets.tcpServer;
var tcp             = chrome.sockets.tcp;
var usb             = chrome.usb;
var serial          = chrome.serial;
var hid             = chrome.hid;
var bluetooth       = chrome.bluetooth;
var bluetoothSocket = chrome.bluetoothSocket;

var socketRecvBuffer = new BufferData();

var serverId    = -1;
var clientId    = -1;
var serialId    = -1;
var hidId       = -1;
var bluetoothId = -1;

var uploadData;

//===init event listeners

chrome.app.runtime.onLaunched.addListener(__onInit);

tcpServer.onAccept.addListener(function(info){
  tcpServer.setPaused(serverId, true);
	clientId = info.clientSocketId;
	tcp.setPaused(clientId, false);
});

tcp.onReceive.addListener(function(info){
  if(info.socketId != clientId){
    return;
  }
  socketRecvBuffer.appendData(info.data);
  parsePacket();
});

tcp.onReceiveError.addListener(function(info){
  if(info.socketId != clientId){
    return;
  }
  console.log("socket error:" + info.resultCode + "," + info.socketId);
  tcp.close(clientId);
  clientId = -1;
  tcpServer.setPaused(serverId, false);
});

usb.onDeviceAdded.addListener(function(device){
  
});

usb.onDeviceRemoved.addListener(function(device){
  
});

serial.onReceive.addListener(function(info){
  if(info.connectionId != serialId){
    return;
  }
  uploadData.onRecv(info.data);
});

hid.onDeviceAdded.addListener(function(device){
  
});

hid.onDeviceRemoved.addListener(function(deviceId){
  
});

bluetooth.onDeviceAdded.addListener(function(device){
  console.log(device);
  if(device.address == "00:05:02:03:08:CE"){
    connectBlothtoothSocket(device);
  }
});

bluetooth.onDeviceChanged.addListener(function(device){
  
});

bluetooth.onDeviceRemoved.addListener(function(device){
  
});

bluetoothSocket.onReceive.addListener(function(info){
  console.log("recv bluetooth socket data",info);
});

//===init


/*
bluetooth.stopDiscovery(function(){
  chrome.runtime.lastError;
  bluetooth.startDiscovery(function(){
    var lastError = chrome.runtime.lastError;
    if(lastError){
      console.error(lastError.message);
    }
  });
});
*/

function __onInit(launchData){
  createServer(function(success){
    if(success){
      createWindow("index.html", 800, 600);
    }else{
      console.error("init error");
    }
  });
}

function createServer(callback){
  tcpServer.create({}, function(info){
    serverId = info.socketId;
  	tcpServer.listen(serverId, "127.0.0.1", 7410, 1, function(retCode){
  	  callback(true);
  	});
  });
}

function createWindow(url, width, height){
  chrome.app.window.create(url, {
    "innerBounds":{
      "width":width,
      "height":height
    }
  });
}

function upload(){
  serial.connect("COM4", {"bitrate":115200}, function(info){
      serialId = info.connectionId;
      console.log(info);
      uploadData.handshake();
    });
}

function sendPacket(bytes){
  var buffer = new Uint8Array(bytes).buffer;
  serial.send(serialId, buffer, function(sendInfo){
    console.log("sendInfo", sendInfo);
  });
}

function handlePacket(msgId, msgData){
  console.log("handle packet", msgId, msgData);
  switch(msgId){
    case 100:
      uploadData = new UnoUploader(msgData);
      upload();
      break;
    case 1:
      serial.getDevices(function(portList){
        reply(msgId, portList);
    	});
      break;
    case 2:
      hid.getDevices({}, function(deviceList){
         reply(msgId, deviceList);
      });
      break;
    case 3:
      bluetooth.getDevices(function(deviceList){
        reply(msgId, deviceList);
      });
      break;
    case 11:
      serial.connect(msgData.path, msgData.options, function(info){
        serialId = info.connectionId;
        reply(msgId, info);
      });
      break;
    case 12:
      hid.connect(msgData.deviceId, function(info){
        var lastError = chrome.runtime.lastError;
        if(lastError){
          console.error(lastError.message);
          return;
        }
        hidId = info.connectionId;
        console.log("connect hid ok:", hidId);
        /*
         hid.receive(hidConnectionId, function(reportId, data){
             console.log("hid recv:", hidConnectionId, reportId,  String.fromCharCode.apply(null,
            new Uint8Array(data)
          ));
          });
          */
      });
      break;
    case 13:
      bluetoothSocket.create({}, function(info){
        bluetoothId = info.socketId;
        bluetoothSocket.connect(bluetoothId,
          msgData.address,
          msgData.uuid,
          function(){
            chrome.runtime.lastError;
        });
      });
      break;
    case 21:
      serial.disconnect(serialId, function(success){
        reply(msgId, success);
      });
      break;
    case 22:
      hid.disconnect(hidId, function(){
        reply(msgId, true);
      });
      break;
    case 23:
      bluetoothSocket.disconnect(bluetoothId, function(){
        bluetoothSocket.close(bluetoothId, function(){
          reply(msgId, true);
        });
      });
      break;
    case 31:
      var buffer = [0xff,0x55,0x08,0x00,0x02,0x08,0x07,0x02,0x00,0x00,0x14,0x00];
      buffer = new Uint8Array(buffer).buffer;
      serial.send(serialId, buffer, function(sendInfo){});
      break;
    case 32:
      var buffer = [12,0xff,0x55,0x08,0x00,0x02,0x08,0x07,0x02,0x00,0x00,0x14,0x00];
      buffer = new Uint8Array(buffer).buffer;
      hid.send(hidId, 0, buffer, function(){
        var lastError = chrome.runtime.lastError;
        if(lastError){
          console.error(lastError.message);
          return;
        }
        console.log("hid send:", hidId);
      });
      break;
    case 33:
      var buffer = [0xff,0x55,0x08,0x00,0x02,0x08,0x07,0x02,0x00,0x00,0x14,0x00];
      buffer = new Uint8Array(buffer).buffer;
      bluetoothSocket.send(bluetoothId, buffer, function(bytesSent){});
      break;
  }
}

function parsePacket(){
  var headSize = 4;
  if(!socketRecvBuffer.isEnough(headSize)){
    return;
  }
  var dataView = socketRecvBuffer.getView(DataView);
  var packetSize = dataView.getUint16(0, true);
  if(!socketRecvBuffer.isEnough(packetSize)){
    return;
  }
  var msgId = dataView.getUint16(2, true);
  var dataSize = packetSize - headSize;
  var msgData = null;
  if(dataSize > 0){
    var dataType = dataView.getUint8(4);
    --dataSize;
    if(dataType == 0){
      msgData = socketRecvBuffer.getJSON(headSize+1, packetSize);
    }else if(dataType == 1){
      msgData = socketRecvBuffer.getArrayBuffer(headSize+1, packetSize);
    }
  }
	handlePacket(msgId, msgData);
	socketRecvBuffer.shiftData(packetSize);
	parsePacket();
}

function reply(msgId, msgData){
  if(Object.prototype.toString.call(msgData) == "[object ArrayBuffer]"){
    console.log("is array");
  }else{
    console.log("is obj");
  }
  var str = JSON.stringify(msgData);
  var buffer = new ArrayBuffer(str.length + 4);
  var dataView = new DataView(buffer);
  dataView.setUint16(0, buffer.byteLength, true);
  dataView.setUint16(2, msgId, true);
  for(var i=0, n=str.length; i<n; ++i){
    dataView.setUint8(i+4, str.charCodeAt(i));
  }
  tcp.send(clientId, buffer, function(sendInfo){});
}





