#pragma once

#include <Arduino.h>

#define send_float(index, value) \
  send_value<float>(index, 2, value)

#define send_uint8(index, value) \
  send_value<uint8_t>(index, 1, value)

#define send_uint16(index, value) \
  send_value<uint16_t>(index, 3, value)


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

