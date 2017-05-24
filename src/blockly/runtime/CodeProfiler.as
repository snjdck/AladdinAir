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
			for each(var info:Array in infoDict){
				info[0] = info[1] = 0;
			}
		}
		
		public function begin(key:String):void
		{
			if(!(key in infoDict)){
				infoDict[key] = [0, 0];
			}
			timestamp = getTimer();
		}
		
		public function end(key:String):void
		{
			var info:Array = infoDict[key];
			info[0] += getTimer() - timestamp;
			info[1] += 1;
		}
		
		public function print():void
		{
			var infoList:Array = [];
			var info:Array;
			var total:int = 0;
			for(var key:String in infoDict){
				info = infoDict[key];
				if(info[0] <= 0){
					continue;
				}
				total += info[0];
				var value:Number = info[0] * 100;
				infoList.push([key, value, value / info[1]]);
			}
			if(total <= 0){
				return;
			}
			trace("/**Profile**/", total);
			infoList.sort(_sortInfo);
			for each(info in infoList){
				trace(Math.round(info[1] / total) + "%\t\t" + Math.round(info[2] / total) + "%\t\t" + info[0]);
			}
		}
		
		private function _sortInfo(a:Array, b:Array):int
		{
			if (a[1] > b[1]) return -1;
			if (a[1] < b[1]) return  1;
			if (a[2] > b[2]) return -1;
			if (a[2] < b[2]) return  1;
			return 0;
		}
	}
}