package com.arduino
{
	import flash.filesystem.File;

	public class BoardNano328 extends BoardInfo
	{
		public function BoardNano328()
		{
			super("atmega328p", "arduino", 57600);
		}
		
		override public function getLibList(rootDir:File, result:Array):void
		{
			result.push(rootDir.resolvePath("hardware/arduino/avr/variants/eightanaloginputs"));
		}
		
		override public function getCompileArgList(result:Vector.<String>):void
		{
			result.push("-DARDUINO_AVR_NANO");
		}
	}
}