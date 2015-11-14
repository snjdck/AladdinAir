package blockly.runtime
{
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class ConditionCalculater
	{
		private var functionProvider:FunctionProvider;
		private var interpreter:Interpreter;
		
		public function ConditionCalculater(interpreter:Interpreter, functionProvider:FunctionProvider)
		{
			this.functionProvider = functionProvider;
			this.interpreter = interpreter;
		}
		
		public function calculate(codeList:Array):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.JUMP_IF_TRUE){
					continue;
				}
				var conditionBeginIndex:int = findConditionCodeBeginIndex(codeList, i);
				var conditionCodes:Array = codeList.slice(conditionBeginIndex, i);
				if(!isConstCondition(conditionCodes)){
					continue;
				}
				var conditionValue:Object = interpreter.calculateAssembly(conditionCodes);
				var jumpCount:int = (conditionValue ? code[1] : 1) + conditionCodes.length;
				codeList[conditionBeginIndex] = OpFactory.Jump(jumpCount);
				codeList[i] = null;
			}
		}
		
		private function findConditionCodeBeginIndex(codeList:Array, jumpTrueIndex:int):int
		{
			var needCount:int = 1;
			for(var i:int=jumpTrueIndex-1; i>=0; --i){
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.PUSH:
						--needCount;
						break;
					case OpCode.CALL:
						needCount += code[2] - code[3];
						break;
					default:
						assert(false);
						continue;
				}
				if(0 == needCount){
					return i;
				}
			}
			return jumpTrueIndex;
		}
		
		private function isConstCondition(codeList:Array):Boolean
		{
			if(1 == codeList.length){
				return true;
			}
			for each(var code:Array in codeList){
				if(code[0] != OpCode.CALL){
					continue;
				}
				if(!functionProvider.isNativeFunction(code[1])){
					return false;
				}
			}
			return true;
		}
	}
}