#include "Router.h"

Router::Router()
:index(0)
{
}

void Router::regHandler(byte id, MsgHandler handler)
{
	handlerList[id] = handler;
}

void Router::setup()
{
	Serial.begin(115200);
}

void Router::loop()
{
	while(Serial.available() > 0){
		buffer[index++] = Serial.read();
	}
	if(index < 3){
		return;
	}
	if(buffer[0] == 0xFF && buffer[1] == 0x55){
		byte dataLen = buffer[2] + 3;
		if(index >= dataLen){
			dispatch();
			moveData(dataLen, index);
			index -= dataLen;
		}
	}else{
		moveData(1, index--);
	}
}

void Router::moveData(byte from, byte to)
{
	for(byte i=from; i<to; ++i){
		buffer[i-from] = buffer[i];
	}
}

void Router::dispatch(){
	byte mode = buffer[4];
	switch(mode){
		case RESET:
		case START:
			break;
		case GET:
		case RUN:{
			MsgHandler handler = handlerList[buffer[5]];
			if(handler != NULL){
				handler(buffer);
			}
		}
			break;
	}
	if(mode != GET){
		Serial.write(0xFF);
		Serial.write(0x55);
		Serial.println();
	}
}
