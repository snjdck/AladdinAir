package com.arduino
{
	import flash.filesystem.File;

	public class BoardLeonardo extends BoardInfo
	{
		public function BoardLeonardo()
		{
			super("atmega32u4", "avr109", 57600);
		}
		
		override public function getLibList(rootDir:File, result:Array):void
		{
			result.push(rootDir.resolvePath("hardware/arduino/avr/variants/leonardo"));
		}
		
		override public function getCompileArgList(result:Vector.<String>):void
		{
			result.push("-DARDUINO_AVR_LEONARDO");
			result.push("-DUSB_VID=0x2341");
			result.push("-DUSB_PID=0x8036");
			result.push('-DUSB_MANUFACTURER="Unknown"');
			result.push('-DUSB_PRODUCT="Arduino Leonardo"');
		}
	}
}