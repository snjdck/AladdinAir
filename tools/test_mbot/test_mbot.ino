#include <Arduino.h>
#include <MeMCore.h>

#include "Router.h"
#include "TypeCast.h"

#define VERSION 0
#define ULTRASONIC_SENSOR 1
#define TEMPERATURE_SENSOR 2
#define LIGHT_SENSOR 3
#define POTENTIONMETER 4
#define JOYSTICK 5
#define GYRO 6
#define SOUND_SENSOR 7
#define RGBLED 8
#define SEVSEG 9
#define MOTOR 10
#define SERVO 11
#define ENCODER 12
#define IR 13
#define IRREMOTE 14
#define PIRMOTION 15
#define INFRARED 16
#define LINEFOLLOWER 17
#define IRREMOTECODE 18
#define SHUTTER 20
#define LIMITSWITCH 21
#define BUTTON 22
#define HUMITURE 23
#define FLAMESENSOR 24
#define GASSENSOR 25
#define COMPASS 26
#define DIGITAL 30
#define ANALOG 31
#define PWM 32
#define SERVO_PIN 33
#define TONE 34
#define BUTTON_INNER 35
#define LEDMATRIX 41
#define TIMER 50
#define TOUCH_SENSOR 51

Router router;

void setup()
{
  router.setup();
  router.regHandler(RGBLED, on_RGB_LED);
  router.regHandler(TONE, on_TONE);
  router.regHandler(SEVSEG, on_SEVSEG);
  router.regHandler(MOTOR, on_MOTOR);
  router.regHandler(JOYSTICK, on_JOYSTICK);
  router.regHandler(LEDMATRIX, on_LEDMATRIX);
  router.regHandler(PWM, on_PWM);
  router.regHandler(DIGITAL, on_DIGITAL);
  router.regHandler(ULTRASONIC_SENSOR, on_ULTRASONIC);
  router.regHandler(TEMPERATURE_SENSOR, on_TEMPERATURE);

  MeRGBLed led(0, 2);
  led.setpin(13);
  led.setColor(0,0,0);
  led.show();
}

void loop()
{
  router.loop();
}

void on_RGB_LED(byte *buffer)
{
  int r = buffer[9];
  int g = buffer[10];
  int b = buffer[11];
  MeRGBLed led(buffer[6], buffer[7], 30);
  led.setColor(r,g,b);
  led.show();
}

void on_TONE(byte *buffer)
{
  MeBuzzer buzzer;
  uint16_t hz = cast_bytes<uint16_t>(buffer, 6);
  if(hz>0){
    buzzer.tone(hz,cast_bytes<uint16_t>(buffer, 8));
  }else{
    buzzer.noTone();
  }
}

void on_SEVSEG(byte *buffer)
{
  Me7SegmentDisplay seg(buffer[6]);
  seg.display(cast_bytes<float>(buffer, 7));
}

void on_MOTOR(byte *buffer){
  MeDCMotor dc(buffer[6]);
  dc.run(cast_bytes<uint16_t>(buffer, 7));
}

void on_JOYSTICK(byte *buffer)
{
  MeDCMotor dc(M1);
  dc.run(cast_bytes<uint16_t>(buffer, 6));
  dc.reset(M2);
  dc.run(cast_bytes<uint16_t>(buffer, 8));
}

void on_LEDMATRIX(byte *buffer)
{
  MeLEDMatrix ledMx(buffer[6]);
  ledMx.setBrightness(6);
  ledMx.setColorIndex(1);
  switch(buffer[7]){
    case 1:
      buffer[11+buffer[10]] = 0;
      ledMx.drawStr(buffer[8],buffer[9],(char*)(buffer+11));
      break;
    case 2:
      ledMx.drawBitmap(buffer[8],buffer[9],16,buffer+10);
      break;
    case 3:
      ledMx.showClock(buffer[9],buffer[10],buffer[8]);
      break;
    case 4:
      ledMx.showNum(cast_bytes<float>(buffer,8),3);
      break;
  }
}

void on_PWM(byte *buffer)
{
  pinMode(buffer[6], OUTPUT);
  analogWrite(buffer[6], buffer[7]);
}

void on_DIGITAL(byte *buffer)
{
  int pin = buffer[6];
  if(RUN == buffer[4]){
    pinMode(pin, OUTPUT);
    digitalWrite(pin, buffer[7]);
  }else{
    pinMode(pin, INPUT);
    send_uint8(buffer[3], digitalRead(pin));
  }
}

void on_ULTRASONIC(byte *buffer)
{
  MeUltrasonicSensor us(buffer[6]);
  float value = (float)us.distanceCm(50000);
  delayMicroseconds(100);
  send_float(buffer[3], value);
}

void on_TEMPERATURE(byte *buffer)
{
  MeTemperature ts(buffer[6], buffer[7]);
  send_float(buffer[3], ts.temperature());
}
