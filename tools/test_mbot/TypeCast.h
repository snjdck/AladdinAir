#pragma once

#include <Arduino.h>

template<typename T>
T cast_bytes(byte *buffer, int offset)
{
  T value;
  byte *p = (byte*)&value;
  for(int i=0; i<sizeof(T); ++i)
    p[i] = buffer[offset+i];
  return value;
}

template<typename T>
void send_value(byte index, byte valueType, T value)
{
  Serial.write(0xFF);
  Serial.write(0x55);
  Serial.write(index);
  Serial.write(valueType);
  byte *p = (byte*)&value;
  for(int i=0; i<sizeof(T); ++i)
    Serial.write(p[i]);
  Serial.println();
}
