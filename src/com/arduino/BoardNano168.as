package com.arduino
{
	import flash.filesystem.File;

	public class BoardNano168 extends BoardInfo
	{
		public function BoardNano168()
		{
			super("atmega168", "arduino", 19200);
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