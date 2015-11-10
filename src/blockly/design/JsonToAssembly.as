package blockly.design
{
	import array.append;
	
	import blockly.OpCode;
	import blockly.OpFactory;

	public class JsonToAssembly
	{
		public function JsonToAssembly()
		{
		}
		
		public function getTotalCode(blockList:Array):Array
		{
			var result:Array = [];
			for each(var block:Object in blockList){
				append(result, getSelfCode(block));
			}
			return result;
		}
		
		private function getSelfCode(block:Object):Array
		{
			switch(block["type"]){
				case "string":
				case "number":
					return [OpFactory.Push(block["value"])];
				case "function":
					return getExpressionCode(block);
				case "break":
					return [[OpCode.BREAK]];
				case "continue":
					return [[OpCode.CONTINUE]];
				case "while":
				case "for":
					return getForCode(block);
				case "if":
					return getIfCode(block);
			}
			return null;
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
			var loop:Array = getTotalCode(block["loop"]);
			var argCode:Array = getSelfCode(block["condition"]);
			
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
		
		private function getIfCode(block:Object):Array
		{
			var result:Array = getSelfCode(block["condition"]);
			
			var caseTrue:Array = getTotalCode(block["caseTrue"]);
			var caseFalse:Array = getTotalCode(block["caseFalse"]);
			
			result.push(OpFactory.JumpIfTrue(caseFalse.length + 2));
			append(result, caseFalse);
			result.push(OpFactory.Jump(caseTrue.length + 1));
			append(result, caseTrue);
			
			return result;
		}
		
		private function getExpressionCode(block:Object):Array
		{
			var argList:Array = block["argList"];
			var n:int = argList != null ? argList.length : 0;
			var result:Array = [];
			for(var i:int=0; i<n; ++i){
				append(result, getSelfCode(argList[i]));
			}
			result.push(OpFactory.Call(block["method"], n));
			return result;
		}
	}
}