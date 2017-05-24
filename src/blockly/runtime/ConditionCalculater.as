package blockly.runtime
{
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class ConditionCalculater
	{
		public function ConditionCalculater(){}
		
		public function calculate(codeList:Array):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.JUMP_IF_TRUE){
					continue;
				}
				var prevIndex:int = i - 1;
				var prevCode:Array = codeList[prevIndex];
				if(prevCode[0] == OpCode.IS_POSITIVE){
					codeList[prevIndex] = OpFactory.Jump(2);
					codeList[i+1][0] = OpCode.JUMP_IF_NOT_POSITIVE;
					continue;
				}
				if(prevCode[0] != OpCode.PUSH){
					continue;
				}
				var jumpCount:int = 1 + (Boolean(prevCode[1]) ? code[1] : 1);
				codeList[prevIndex] = OpFactory.Jump(jumpCount);
				codeList[i] = null;
			}
		}
	}
}