package com.arduino
{
	public class BoardInfoFactory
	{
		static public function GetBoardInfo(boardType:String):BoardInfo
		{
			switch(boardType)
			{
				case BoardType.uno:
					return new BoardInfo("atmega328p", "arduino", 115200);
				case BoardType.leonardo:
					return new BoardInfo("atmega32u4", "avr109", 57600);
				case BoardType.mega1280:
					return new BoardInfo("atmega1280", "wiring", 57600);
				case BoardType.mega2560:
					return new BoardInfo("atmega2560", "wiring", 115200);
				case BoardType.nano328:
					return new BoardInfo("atmega328p", "arduino", 57600);
				case BoardType.nano168:
					return new BoardInfo("atmega168", "arduino", 19200);
			}
			return null;
		}
	}
}