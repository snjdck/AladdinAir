package blockly.design
{
	import array.append;
	
	import blockly.BuiltInMethod;
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
			if(block is String){
				return [OpFactory.Push(block)];
			}
			switch(block["type"]){
				case "function":
					return getExpressionCode(block);
				case "break":
					return [[OpCode.BREAK]];
				case "continue":
					return [[OpCode.CONTINUE]];
				case "while":
					return getForCode(block);
				case "if":
					return getIfCode(block);
			}
			return null;
		}
		
		
		private function getForeverCode(block:Object):Array
		{
			var loop:Array = block["loop"];
			var result:Array;
			if(loop != null){
				result = getTotalCode(loop);
				result.push(OpFactory.Jump(-result.length));
			}else{
				result = [OpFactory.Jump(0)];
			}
			return result;
		}
		
		private function getForCode(block:Object):Array
		{
			var loop:Array = block["loop"];
			var argCode:Array = getSelfCode(block["condition"]);
			var result:Array;
			if(loop != null){
				result = getTotalCode(loop);
				replaceBreakContinue(result, result.length + argCode.length);
				result.unshift(OpFactory.Jump(result.length));
				append(result, argCode);
				result.push(OpFactory.JumpIfTrue(1-result.length));
			}else{
				result = argCode.slice();
				result.push(OpFactory.JumpIfTrue(-result.length));
			}
			return result;
		}
		
		private function replaceBreakContinue(codeList:Array, totalCodeLength:int):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] == OpCode.BREAK){
					codeList[i] = OpFactory.Jump(totalCodeLength - i);
					continue;
				}
				if(code[0] == OpCode.CONTINUE){
					var offset:int = n - i - 1;
					if(offset > 0){
						codeList[i] = OpFactory.Jump(offset);
					}else{
						codeList.pop();
					}
				}
			}
		}
		
		private function getIfCode(block:Object):Array
		{
			var result:Array = [];
			
			var sub1Code:Array;
			var sub2Code:Array;
			
			var condition:Object = block["condition"];
			var caseTrue:Array = block["caseTrue"];
			var caseFalse:Array = block["caseFalse"];
			
			if(caseTrue != null && caseFalse != null){
				sub1Code = getTotalCode(caseTrue);
				sub2Code = getTotalCode(caseFalse);
				append(result, getSelfCode(condition));
				result.push(OpFactory.JumpIfTrue(sub2Code.length + 2));
				append(result, sub2Code);
				result.push(OpFactory.Jump(sub1Code.length + 1));
				append(result, sub1Code);
			}else if(caseTrue != null){
				sub1Code = getTotalCode(caseTrue);
				append(result, getSelfCode(condition));
				result.push(OpFactory.Call(BuiltInMethod.NOT, 1));
				result.push(OpFactory.JumpIfTrue(sub1Code.length + 1));
				append(result, sub1Code);
			}else if(caseFalse != null){
				sub2Code = getTotalCode(caseFalse);
				append(result, getSelfCode(condition));
				result.push(OpFactory.JumpIfTrue(sub2Code.length + 1));
				append(result, sub2Code);
			}else if(!(condition is String)){
				append(result, getSelfCode(condition));
				result.push(OpFactory.Pop(1));
			}
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