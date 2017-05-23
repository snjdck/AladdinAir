package blockly.runtime
{
	import flash.utils.getTimer;

	internal class CodeProfiler
	{
		private var infoDict:Object = {};
		private var timestamp:int;
		
		public function CodeProfiler(){}
		
		public function reset():void
		{
			for(var key:String in infoDict){
				infoDict[key] = 0;
			}
		}
		
		public function begin(key:String):void
		{
			if(!(key in infoDict)){
				infoDict[key] = 0;
			}
			timestamp = getTimer();
		}
		
		public function end(key:String):void
		{
			infoDict[key] += getTimer() - timestamp;
		}
		
		public function print():void
		{
			var total:int = 0;
			for each(var time:int in infoDict){
				total += time;
			}
			trace("/**Profile**/", total);
			for(var key:String in infoDict){
				if(infoDict[key] <= 0){
					continue;
				}
				trace(Math.round(infoDict[key] * 100 / total) + "%\t\t" + key);
			}
		}
	}
}