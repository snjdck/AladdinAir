package blockly.runtime
{
	import flash.utils.setTimeout;
	
	public class ArduinoInterpreter extends MyInterpreter
	{
		public function ArduinoInterpreter()
		{
			regMethodHandler("getUltrasonic", getUltrasonic);
			regMethodHandler("<", onLess);
			regMethodHandler(">", onGreater);
			regMethodHandler("=", onEqual);
			regMethodHandler("&", onAnd);
			regMethodHandler("|", onOr);
			regMethodHandler("randomFrom:to:", onRandomInt);
		}
		
		private function onRandomInt(thread:Thread, argList:Array):void
		{
			var min:int = argList[0];
			var max:int = argList[1];
			var val:int = min + (max - min) * Math.random();
			thread.push(val);
		}
		
		private function onAnd(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] && argList[1]);
		}
		
		private function onOr(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] || argList[1]);
		}
		
		private function onLess(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] < argList[1]);
		}
		
		private function onGreater(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] > argList[1]);
		}
		
		private function onEqual(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] == argList[1]);
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