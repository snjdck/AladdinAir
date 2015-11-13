package blockly.util
{
	import flash.utils.setTimeout;
	
	import blockly.runtime.FunctionProvider;
	import blockly.runtime.Thread;
	
	public class ArduinoFunctionProvider extends FunctionProvider
	{
		public function ArduinoFunctionProvider()
		{
			register("getUltrasonic", getUltrasonic);
			register("randomFrom:to:", onRandomInt);
		}
		
		private function onRandomInt(thread:Thread, argList:Array):void
		{
			var min:int = argList[0];
			var max:int = argList[1];
			var val:int = min + (max - min) * Math.random();
			thread.push(val);
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