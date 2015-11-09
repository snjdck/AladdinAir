package blockly.runtime
{
	import flash.utils.setTimeout;
	
	import blockly.Interpreter;
	import blockly.MyInterpreter;
	
	public class ArduinoInterpreter extends MyInterpreter
	{
		public function ArduinoInterpreter()
		{
			regMethodHandler("getUltrasonic", getUltrasonic);
		}
		
		private function getUltrasonic(interpreter:Interpreter, argList:Array):void
		{
			interpreter.suspend();
			
			setTimeout(function():void{
				interpreter.push(101);
				interpreter.resume();
			}, 1000);
		}
	}
}