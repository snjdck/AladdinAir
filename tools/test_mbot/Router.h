#pragma once

#include <Arduino.h>

#define GET 1
#define RUN 2
#define RESET 4
#define START 5

typedef void (*MsgHandler)(byte *buffer);

class Router
{
public:
	Router();

	void setup();
	void loop();

	void regHandler(byte id, MsgHandler handler);

private:
	void moveData(byte from, byte to);
	void dispatch();

private:
	MsgHandler handlerList[0x80];
	byte buffer[64];
	byte index;
};
