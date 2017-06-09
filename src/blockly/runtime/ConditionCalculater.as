package blockly.runtime
{
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class ConditionCalculater
	{
		public function ConditionCalculater(){}
		
		public function calculate(codeList:Array):void
		{
			for(var i:int=1, n:int=codeList.length; i<n; ++i){
				var prevIndex:int = i - 1;
				var prevCode:Array = codeList[prevIndex];
				var code:Array = codeList[i];
				
				if(code[0] == OpCode.JUMP_IF_FALSE){
					if(prevCode[0] == OpCode.PUSH){
						codeList[prevIndex] = OpFactory.Jump(1);
						code[0] = OpCode.JUMP;
						if(prevCode[1]){
							code[1] = 1;
						}
					}else if(prevCode[0] == OpCode.IS_POSITIVE){
						codeList[prevIndex] = OpFactory.Jump(1);
						code[0] = OpCode.JUMP_IF_NOT_POSITIVE;
					}
				}
			}
		}
	}
}