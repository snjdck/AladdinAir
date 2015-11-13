package blockly.runtime
{
	import blockly.OpCode;

	internal class DeadCodeCleaner
	{
		public function DeadCodeCleaner()
		{
		}
		
		public function clean(codeList:Array):Array
		{
			var newCodeList:Array = generateSyntaxTree(codeList, 0, codeList.length);
			trace("dead code", JSON.stringify(newCodeList));
			return codeList;
		}
		
		private function removeDeadCode(codeList:Array):void
		{
			
		}
		
		private function generateSyntaxTree(codeList:Array, begin:int, end:int):Array
		{
			var result:Array = [];
			var info:Object;
			while(begin < end){
				var code:Array = codeList[begin];
				switch(code[0]){
					case OpCode.JUMP_IF_TRUE:
						info = parseIf(codeList, begin);
						break;
					case OpCode.JUMP:
						info = parseLoop(codeList, begin);
						break;
					default:
						result.push(code);
						++begin;
						continue;
				}
				result.push(info);
				begin = info["endIndex"];
			}
			return result;
		}
		
		private function parseIf(codeList:Array, index:int):Object
		{
			var jumpIndex:int = index + codeList[index][1] - 1;
			var endIndex:int = jumpIndex + codeList[jumpIndex][1];
			return {
				"type":"if",
				"condition":codeList.slice(index, index+1),
				"caseTrue":generateSyntaxTree(codeList, jumpIndex+1, endIndex),
				"caseFalse":generateSyntaxTree(codeList, index+1, jumpIndex),
				"endIndex":endIndex
			};
		}
		
		private function parseLoop(codeList:Array, index:int):Object
		{
			var conditionIndex:int = index + codeList[index][1];
			var endIndex:int = getLoopEndIndex(codeList, conditionIndex);
			return {
				"type":"loop",
				"condition":codeList.slice(conditionIndex, endIndex),
				"code":generateSyntaxTree(codeList, index+1, conditionIndex),
				"endIndex":endIndex
			};
		}
		
		private function getLoopEndIndex(codeList:Array, index:int):int
		{
			for(;;++index){
				if(codeList[index][0] == OpCode.JUMP_IF_TRUE){
					return index + 1;
				}
			}
			return -1;
		}
	}
}