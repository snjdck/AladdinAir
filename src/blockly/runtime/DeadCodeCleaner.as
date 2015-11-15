package blockly.runtime
{
	import blockly.OpCode;

	internal class DeadCodeCleaner
	{
		public function DeadCodeCleaner()
		{
		}
		
		public function clean(codeList:Array):void
		{
			var codeUsage:Array = [];
			markCodeUsage(codeList, codeUsage, 0);
			removeAndAdjustCode(codeList, parseDeadInfo(codeUsage, codeList.length));
			removeAndAdjustCode(codeList, getJump1Info(codeList));
		}
		
		private function markCodeUsage(codeList:Array, codeUsage:Array, fromIndex:int):void
		{
			var index:int = fromIndex;
			var totalCount:int = codeList.length;
			while(index < totalCount){
				if(codeUsage[index]){
					return;
				}
				codeUsage[index] = true;
				var code:Array = codeList[index];
				switch(code[0]){
					case OpCode.JUMP_IF_TRUE:
						markCodeUsage(codeList, codeUsage, index+1);
						//fallthrough
					case OpCode.JUMP:
						index += code[1];
						break;
					default:
						++index;
				}
			}
		}
		
		private function parseDeadInfo(codeUsage:Array, codeCount:int):Array
		{
			var deadCodeInfo:Array = [];
			var isInDeadCode:Boolean;
			for(var i:int=0; i<codeCount; ++i){
				if(Boolean(codeUsage[i]) == isInDeadCode){
					isInDeadCode = !isInDeadCode;
					deadCodeInfo.push(i);
				}
			}
			if(isInDeadCode){
				deadCodeInfo.push(codeCount);
			}
			return deadCodeInfo;
		}
		
		private function removeAndAdjustCode(codeList:Array, deadCodeInfo:Array):void
		{
			removeDeadCode(codeList, deadCodeInfo);
			adjustJumpCode(codeList, deadCodeInfo);
		}
		
		private function removeDeadCode(codeList:Array, deadCodeInfo:Array):void
		{
			for(var i:int=deadCodeInfo.length-1; i>0; i-=2){
				var begin:int = deadCodeInfo[i-1];
				var end:int = deadCodeInfo[i];
				codeList.splice(begin, end-begin);
			}
		}
		
		private function adjustJumpCode(codeList:Array, deadCodeInfo:Array):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.JUMP:
					case OpCode.JUMP_IF_TRUE:
						break;
					default:
						continue;
				}
				var jumpCount:int = code[1];
				if(jumpCount > 0){
					code[1] -= calcSpace(deadCodeInfo, i, i+jumpCount);
				}else if(jumpCount < 0){
					code[1] += calcSpace(deadCodeInfo, i+jumpCount, i);
				}
			}
		}
		
		private function calcSpace(deadCodeInfo:Array, fromIndex:int, toIndex:int):int
		{
			var result:int = 0;
			for(var i:int=0; i<deadCodeInfo.length; i+=2){
				var begin:int = deadCodeInfo[i];
				var end:int = deadCodeInfo[i+1];
				if(fromIndex < begin && end <= toIndex){
					result += end - begin;
				}
			}
			return result;
		}
		
		private function getJump1Info(codeList:Array):Array
		{
			var jumpCodeInfo:Array = [];
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] == OpCode.JUMP && code[1] == 1){
					jumpCodeInfo.push(i, i+1);
				}
			}
			return jumpCodeInfo;
		}
	}
}