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
			//jump_if_true won't be the first code, so I use i > 0 as condition.
			for(var i:int=codeList.length-1; i>0; --i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.JUMP_IF_TRUE){
					continue;
				}
				var conditionBeginIndex:int = findConditionCodeBeginIndex(codeList, i);
				var conditionCodes:Array = codeList.slice(conditionBeginIndex, i);
				if(isConstCondition(conditionCodes)){
					var conditionValue:Object = interpreter.calculateAssembly(conditionCodes);
					var jumpCount:int = (conditionValue ? code[1] : 1) + conditionCodes.length;
					codeList[conditionBeginIndex] = OpFactory.Jump(jumpCount);
					for(; i > conditionBeginIndex; --i){
						codeList[i] = null;
					}
				}else{
					i = conditionBeginIndex;
				}
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
			for(var i:int=codeList.length-1; i>=0; --i){
				var code:Array = codeList[i];
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