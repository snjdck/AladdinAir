package blockly.design
{
	public class ArduinoCmdDict
	{
		private var cmdDict:Object;
		
		public function ArduinoCmdDict()
		{
			cmdDict = {};
		}
		
		public function addCmd(cmd:String, handler:Function):void
		{
			cmdDict[cmd] = handler;
		}
		
		public function hasCmd(cmd:String):Boolean
		{
			return cmdDict[cmd] != null;
		}
		
		public function translate(output:ArduinoOutput, cmd:String, argList:Array, indent:int=0):String
		{
			var handler:Function = cmdDict[cmd];
			return handler(output, cmd, argList, indent);
		}
	}
}