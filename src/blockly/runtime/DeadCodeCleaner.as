package blockly.runtime
{
	import blockly.OpCode;

	internal class DeadCodeCleaner
	{
		private const codeUsage:Vector.<Boolean> = new Vector.<Boolean>();
		
		public function DeadCodeCleaner(){}
		
		public function clean(codeList:Array):void
		{
			initCodeUsage(codeList);
			calcCodeUsage(codeList, 0);
			markJump1Codes(codeList);
			adjustJumpCode(codeList);
			removeDeadCode(codeList);
		}
		
		private function initCodeUsage(codeList:Array):void
		{
			var n:int = Math.min(codeList.length, codeUsage.length);
			if(codeUsage.length < codeList.length){
				codeUsage.length = codeList.length;
			}
			while(n-- > 0){
				if(codeUsage[n]){
					codeUsage[n] = false;
				}
			}
		}
		
		private function calcCodeUsage(codeList:Array, fromIndex:int):void
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
					case OpCode.NEW_FUNCTION:
					case OpCode.JUMP_IF_FALSE:
					case OpCode.JUMP_IF_NOT_POSITIVE:
						calcCodeUsage(codeList, index+1);
						//fallthrough
					case OpCode.JUMP:
						index += code[1];
						break;
					case OpCode.RETURN:
						return;
					default:
						++index;
				}
			}
		}
		
		private function markJump1Codes(codeList:Array):void
		{
			loop:
			for(var i:int=codeList.length-1; i>=0; --i){
				if(!codeUsage[i]){
					continue;
				}
				var code:Array = codeList[i];
				if(code[0] != OpCode.JUMP || code[1] <= 0){
					continue;
				}
				var jumpIndex:int = i + code[1];
				while(i < --jumpIndex){
					if(codeUsage[jumpIndex]){
						continue loop;
					}
				}
				codeUsage[i] = false;
			}
		}
		
		private function removeDeadCode(codeList:Array):void
		{
			var isInDeadCode:Boolean = false;
			var index:int;
			for(var i:int=codeList.length-1; i>=0; --i){
				if(codeUsage[i] != isInDeadCode){
					continue;
				}
				isInDeadCode = !isInDeadCode;
				if(isInDeadCode){
					index = i;
				}else{
					codeList.splice(i+1, index - i);
				}
			}
			if(isInDeadCode){
				codeList.splice(0, index + 1);
			}
		}
		
		private function adjustJumpCode(codeList:Array):void
		{
			for(var i:int=codeList.length-1; i>=0; --i){
				if(!codeUsage[i]){
					continue;
				}
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.JUMP:
					case OpCode.JUMP_IF_FALSE:
					case OpCode.JUMP_IF_NOT_POSITIVE:
					case OpCode.NEW_FUNCTION:
						break;
					default:
						continue;
				}
				var jumpCount:int = code[1];
				if(jumpCount > 0){
					code[1] -= calcSpace(i, i+jumpCount);
				}else if(jumpCount < 0){
					code[1] += calcSpace(i+jumpCount, i);
				}
			}
		}
		
		private function calcSpace(fromIndex:int, toIndex:int):int
		{
			var result:int = 0;
			for(var i:int=fromIndex+1; i<toIndex; ++i){
				if(!codeUsage[i]){
					++result;
				}
			}
			return result;
		}
	}
}