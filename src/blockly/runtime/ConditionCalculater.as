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
			calculateExpression(codeList);
			mergeJumpIfTrue(codeList);
		}
		
		private function mergeJumpIfTrue(codeList:Array):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.JUMP_IF_TRUE){
					continue;
				}
				var prevIndex:int = i - 1;
				var prevCode:Array = codeList[prevIndex];
				if(prevCode[0] != OpCode.PUSH){
					continue;
				}
				var jumpCount:int = 1 + (Boolean(prevCode[1]) ? code[1] : 1);
				codeList[prevIndex] = OpFactory.Jump(jumpCount);
				codeList[i] = null;
			}
		}
		
		private function calculateExpression(codeList:Array):void
		{
			for(var i:int=codeList.length-1; i>=0; --i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.CALL || code[3] == 0){
					continue;
				}
				var conditionBeginIndex:int = findConditionCodeBeginIndex(codeList, i);
				if(!isConstCondition(codeList, conditionBeginIndex, i)){
					continue;
				}
				var conditionCodes:Array = codeList.slice(conditionBeginIndex, i+1);
				var conditionValue:Object = interpreter.calculateAssembly(conditionCodes);
				if(conditionBeginIndex < i){
					codeList[conditionBeginIndex] = OpFactory.Jump(i - conditionBeginIndex);
				}
				codeList[i] = OpFactory.Push(conditionValue);
				i = conditionBeginIndex;
			}
		}
		
		private function findConditionCodeBeginIndex(codeList:Array, fromIndex:int):int
		{
			var needCount:int = 1;
			for(var i:int=fromIndex; i>=0; --i){
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.LOAD_SLOT:
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
			return fromIndex;
		}
		
		private function isConstCondition(codeList:Array, fromIndex:int, toIndex:int):Boolean
		{
			for(var i:int=fromIndex; i<=toIndex; ++i){
				var code:Array = codeList[i];
				switch(code[0]){
					case OpCode.LOAD_SLOT:
						return false;
					case OpCode.CALL:
						if(!functionProvider.isNativeFunction(code[1])){
							return false;
						}
						break;
				}
			}
			return true;
		}
	}
}