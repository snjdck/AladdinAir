package blockly.runtime
{
	internal class FunctionParams
	{
		private var paramList:Array;
		private var indexList:Array;
		private var count:int;
		
		public function FunctionParams(paramList:Array, indexList:Array)
		{
			this.paramList = paramList;
			this.indexList = indexList;
			count = indexList.length;
		}
		
		public function getArgs(argList:Array):Array
		{
			for(var i:int=0; i<count; ++i){
				paramList[indexList[i]] = argList[i];
			}
			return paramList;
		}
		
		public function toJSON(_:*):Object
		{
			return [paramList, indexList];
		}
	}
}