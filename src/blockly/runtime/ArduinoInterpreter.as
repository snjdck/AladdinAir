package blockly.runtime
{
	import flash.utils.setTimeout;
	
	
	public class ArduinoInterpreter extends MyInterpreter
	{
		public function ArduinoInterpreter()
		{
			regMethodHandler("getUltrasonic", getUltrasonic);
		}
		
		private function getUltrasonic(thread:Thread, argList:Array):void
		{
			thread.suspend();
			
			setTimeout(function():void{
				thread.push(101);
				thread.resume();
			}, 1000);
		}
	}
}