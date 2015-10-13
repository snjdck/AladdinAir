package com.arduino
{
	public class BoardInfo
	{
		public var partno:String;
		public var programmer:String;
		public var baudrate:int;
		
		public function BoardInfo(partno:String, programmer:String, baudrate:int)
		{
			this.partno = partno;
			this.programmer = programmer;
			this.baudrate = baudrate;
		}
	}
}