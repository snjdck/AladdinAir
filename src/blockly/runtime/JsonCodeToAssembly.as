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
			return genStatementCode(blockList);
		}
		
		private function genStatementCode(blockList:Array):Array
		{
			var result:Array = [];
			var n:int = blockList != null ? blockList.length : 0;
			for(var i:int=0; i<n; ++i){
				var block:Object = blockList[i];
				switch(block["type"]){
					case "break":
						if(loopCount > 0){
							result.push([OpCode.BREAK]);
						}
						break;
					case "continue":
						if(loopCount > 0){
							result.push([OpCode.CONTINUE]);
						}
						break;
					case "function":
						append(result, genFunctionCode(block));
						break;
					case "while":
					case "for":
						append(result, genForCode(block));
						break;
					case "if":
						append(result, genIfCode(blockList, i));
						break;
				}
			}
			return result;
		}
		
		private function genExpressionCode(block:Object, blockList:Array=null):Array
		{
			switch(block["type"]){
				case "string":
				case "number":
					return [OpFactory.Push(block["value"])];
				case "function":
					return genFunctionCode(block);
			}
			return null;
		}
		
		private function genFunctionCode(block:Object):Array
		{
			var argList:Array = block["argList"];
			var n:int = argList != null ? argList.length : 0;
			var result:Array = [];
			for(var i:int=0; i<n; ++i){
				append(result, genExpressionCode(argList[i]));
			}
			result.push(OpFactory.Call(block["method"], n, block["retCount"]));
			return result;
		}
		
		private function genForCode(block:Object):Array
		{
			var result:Array = genStatementCode(block["init"]);
			var iter:Array = genStatementCode(block["iter"]);
			var argCode:Array = genExpressionCode(block["condition"]);
			
			++loopCount;
			var loop:Array = genStatementCode(block["loop"]);
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

		private function genIfCodeImpl(condition:Object, caseTrue:Array, caseFalse:Array):Array
		{
			var result:Array = genExpressionCode(condition);
			
			result.push(OpFactory.JumpIfTrue(caseFalse.length + 2));
			append(result, caseFalse);
			result.push(OpFactory.Jump(caseTrue.length + 1));
			append(result, caseTrue);
			
			return result;
		}
		
		private function genIfCode(blockList:Array, index:int):Array
		{
			var block:Object = blockList[index];
			return genIfCodeImpl(block["condition"], genStatementCode(block["code"]), genElseCode(blockList, index + 1));
		}
		
		private function genElseCode(blockList:Array, index:int):Array
		{
			if(index < blockList.length){
				var block:Object = blockList[index];
				switch(block["type"]){
					case "else if":
						return genIfCode(blockList, index);
					case "else":
						return genStatementCode(block["code"]);
				}
			}
			return [];
		}
	}
}