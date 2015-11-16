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
			var codeUsage:Vector.<Boolean> = new Vector.<Boolean>(codeList.length, true);
			calcCodeUsage(codeList, codeUsage, 0);
			markJump1Codes(codeList, codeUsage);
			var deadCodeInfo:Vector.<int> = calcDeadCodeInfo(codeUsage);
			removeDeadCode(codeList, deadCodeInfo);
			adjustJumpCode(codeList, deadCodeInfo);
			checkResult(codeList);
		}
		
		private function calcCodeUsage(codeList:Array, codeUsage:Vector.<Boolean>, fromIndex:int):void
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
						calcCodeUsage(codeList, codeUsage, index+1);
						//fallthrough
					case OpCode.JUMP:
						index += code[1];
						break;
					default:
						++index;
				}
			}
		}
		
		private function calcDeadCodeInfo(codeUsage:Vector.<Boolean>):Vector.<int>
		{
			var deadCodeInfo:Vector.<int> = new Vector.<int>();
			var isInDeadCode:Boolean;
			for(var i:int=0, n:int=codeUsage.length; i<n; ++i){
				if(codeUsage[i] == isInDeadCode){
					isInDeadCode = !isInDeadCode;
					deadCodeInfo.push(i);
				}
			}
			if(isInDeadCode){
				deadCodeInfo.push(n);
			}
			return deadCodeInfo;
		}
		
		private function markJump1Codes(codeList:Array, codeUsage:Vector.<Boolean>):void
		{
			loop:
			for(var i:int=codeUsage.length-1; i>=0; --i){
				if(!codeUsage[i]){
					continue;
				}
				var code:Array = codeList[i];
				if(code[0] != OpCode.JUMP || code[1] < 1){
					continue;
				}
				var jumpIndex:int = i + code[1];
				for(var j:int=i+1; j<jumpIndex; ++j){
					if(codeUsage[j]){
						continue loop;
					}
				}
				codeUsage[i] = false;
			}
		}
		
		private function removeDeadCode(codeList:Array, deadCodeInfo:Vector.<int>):void
		{
			for(var i:int=deadCodeInfo.length-1; i>0; i-=2){
				var begin:int = deadCodeInfo[i-1];
				var end:int = deadCodeInfo[i];
				codeList.splice(begin, end-begin);
			}
		}
		
		private function calcSpace(deadCodeInfo:Vector.<int>, fromIndex:int, toIndex:int):int
		{
			var result:int = 0;
			for(var i:int=deadCodeInfo.length-1; i>0; i-=2){
				var begin:int = deadCodeInfo[i-1];
				if(begin < fromIndex){
					break;
				}
				var end:int = deadCodeInfo[i];
				if(end <= toIndex){
					result += end - begin;
				}
			}
			return result;
		}
		
		private function adjustJumpCode(codeList:Array, deadCodeInfo:Vector.<int>):void
		{
			for(var i:int=codeList.length-1; i>=0; --i){
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
		
		private function checkResult(codeList:Array):void
		{
			for(var i:int=codeList.length-1; i>=0; --i){
				var code:Array = codeList[i];
				assert(code[0] != OpCode.JUMP || code[1] != 1);
			}
		}
	}
}