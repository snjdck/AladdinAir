package blockly.runtime
{
	import array.append;
	
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class JsonCodeToAssembly
	{
		private var loopCount:int;
		
		public function JsonCodeToAssembly()
		{
		}
		
		public function translate(blockList:Array):Array
		{
			assert(loopCount == 0);
			return getTotalCode(blockList);
		}
		
		private function getTotalCode(blockList:Array):Array
		{
			var result:Array = [];
			for each(var block:Object in blockList){
				append(result, getSelfCode(block, blockList));
			}
			return result;
		}
		
		private function getSelfCode(block:Object, blockList:Array=null):Array
		{
			switch(block["type"]){
				case "string":
				case "number":
					return [OpFactory.Push(block["value"])];
				case "function":
					return getExpressionCode(block);
				case "break":
					if(loopCount > 0){
						return [[OpCode.BREAK]];
					}
					break;
				case "continue":
					if(loopCount > 0){
						return [[OpCode.CONTINUE]];
					}
					break;
				case "while":
				case "for":
					return getForCode(block);
				case "if":
					return getIfCode(getIfBlockList(block, blockList));
			}
			return null;
		}
		
		private function getExpressionCode(block:Object):Array
		{
			var argList:Array = block["argList"];
			var n:int = argList != null ? argList.length : 0;
			var result:Array = [];
			for(var i:int=0; i<n; ++i){
				append(result, getSelfCode(argList[i]));
			}
			result.push(OpFactory.Call(block["method"], n, block["retCount"]));
			return result;
		}
		
		private function getForeverCode(block:Object):Array
		{
			var result:Array = getTotalCode(block["loop"]);
			result.push(OpFactory.Jump(-result.length));
			return result;
		}
		
		private function getForCode(block:Object):Array
		{
			var result:Array = getTotalCode(block["init"]);
			var iter:Array = getTotalCode(block["iter"]);
			var argCode:Array = getSelfCode(block["condition"]);
			++loopCount;
			var loop:Array = getTotalCode(block["loop"]);
			--loopCount;
			
			var loopCount:int = loop.length + iter.length;
			var totalCount:int = loopCount + argCode.length;
			
			replaceBreakContinue(loop, totalCount + 1);
			
			result.push(OpFactory.Jump(loopCount + 1));
			append(result, loop);
			append(result, iter);
			append(result, argCode);
			result.push(OpFactory.JumpIfTrue(-totalCount));
			
			return result;
		}
		
		private function replaceBreakContinue(codeList:Array, totalCodeLength:int):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				switch(codeList[i][0]){
					case OpCode.BREAK:
						codeList[i] = OpFactory.Jump(totalCodeLength - i);
						break;
					case OpCode.CONTINUE:
						codeList[i] = OpFactory.Jump(n - i);
						break;
				}
			}
		}

		private function getIfCodeImpl(condition:Object, caseTrue:Array, caseFalse:Array):Array
		{
			var result:Array = getSelfCode(condition);
			
			result.push(OpFactory.JumpIfTrue(caseFalse.length + 2));
			append(result, caseFalse);
			result.push(OpFactory.Jump(caseTrue.length + 1));
			append(result, caseTrue);
			
			return result;
		}
		
		private function getIfCode(blockList:Array):Array
		{
			if(blockList.length <= 0){
				return [];
			}
			var block:Object = blockList.shift();
			switch(block["type"]){
				case "else if":
				case "if":
					return getIfCodeImpl(block["condition"], getTotalCode(block["code"]), getIfCode(blockList));
				case "else":
					return getTotalCode(block["code"]);
			}
			return null;
		}
		
		private function getIfBlockList(block:Object, blockList:Array):Array
		{
			var result:Array = [block];
			var i:int = blockList.indexOf(block) + 1;
			for(var n:int=blockList.length; i < n; ++i){
				block = blockList[i];
				var blockType:String = block["type"];
				if("else if" == blockType){
					result.push(block);
				}else{
					if("else" == blockType){
						result.push(block);
					}
					break;
				}
			}
			return result;
		}
	}
}