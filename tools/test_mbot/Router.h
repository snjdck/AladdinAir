#pragma once

#include <Arduino.h>

#include "TypeCast.h"

#define GET 1
#define RUN 2
#define RESET 4
#define START 5

template<byte handlerCount, byte bufferSize>
class Router
{
	typedef void (*MsgHandler)(byte*);

public:
	Router()
	:index(0)
	{}

	void setup()
	{
		Serial.begin(115200);
	}

	void loop()
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

	void regHandler(byte id, MsgHandler handler)
	{
		handlerList[id] = handler;
	}

	float read_float(int offset)
	{
		return cast_bytes<float>(buffer, offset);
	}

	uint16_t read_uint16(int offset)
	{
		return cast_bytes<uint16_t>(buffer, offset);
	}

	void send_float(float value)
	{
		send_value(buffer[3], 2, value);
	}

	void send_uint8(uint8_t value)
	{
		send_value(buffer[3], 1, value);
	}

	void send_uint16(uint16_t value)
	{
		send_value(buffer[3], 3, value);
	}

private:
	void moveData(byte from, byte to)
	{
		for(byte i=from; i<to; ++i){
			buffer[i-from] = buffer[i];
		}
	}

	void dispatch()
	{
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

private:
	MsgHandler handlerList[handlerCount];
	byte buffer[bufferSize];
	byte index;
};


