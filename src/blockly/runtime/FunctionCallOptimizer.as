package blockly.runtime
{
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class FunctionCallOptimizer
	{
		public function FunctionCallOptimizer(){}
		
		public function optimize(codeList:Array):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.CALL:
					case OpCode.INVOKE:
						break;
					default:
						continue;
				}
				findArgs(codeList, i, code[code.length-2]);
			}
		}
		
		private function findIndex(codeList:Array, fromIndex:int, argCount:int):int
		{
			for(var i:int=fromIndex-1; i>=0; --i){
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.PUSH:
					case OpCode.GET_VAR:
						--argCount;
						break;
					case OpCode.CALL:
						argCount += code[2] - code[3];
						break;
					case OpCode.JUMP:
						assert(code[1] == 1);
						break;
					default:
						assert(false, code[0]);
				}
				if(0 == argCount){
					return i;
				}
			}
			return -1;
		}
		
		private function findArgs(codeList:Array, fromIndex:int, argCount:int):void
		{
			var foundCount:int = 0;
			var indexList:Array = [];
			var paramList:Array = new Array(argCount);
			for(var i:int=fromIndex-1; i>=0; --i){
				if(0 == argCount){
					break;
				}
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.PUSH:
						--argCount;
						if(argCount >= 0){
							++foundCount;
							paramList[argCount] = code[1];
							codeList[i] = OpFactory.Jump(1);
						}
						break;
					case OpCode.JUMP:
						assert(code[1] == 1);
						break;
					case OpCode.CALL:
						if(code[2] > 0){
							i = findIndex(codeList, i, code[2]);
						}
						//fallthrough
					case OpCode.GET_VAR:
						--argCount;
						if(argCount >= 0){
							indexList.unshift(argCount);
						}
						break;
					default:
						assert(false, code[0]);
				}
			}
			if(foundCount <= 0){
				return;
			}
			code = codeList[fromIndex];
			code[code.length-2] -= foundCount;
			code[code.length] = [paramList, indexList];
		}
	}
}