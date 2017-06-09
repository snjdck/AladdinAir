package blockly.runtime
{
	import blockly.OpCode;

	internal class AssemblyOptimizer
	{
		static private const jumpOpList:Array = [OpCode.JUMP];
		static private const conditionJumpOpList:Array = [OpCode.JUMP_IF_FALSE, OpCode.JUMP_IF_NOT_POSITIVE];
		static private const stack:Vector.<int> = new Vector.<int>();
		
		public function AssemblyOptimizer(){}
		
		public function optimize(codeList:Array):void
		{
			runPass(codeList, jumpOpList, optimizeJump);
			runPass(codeList, conditionJumpOpList, optimizeConditionJump);
		}
		
		private function runPass(codeList:Array, opList:Array, handler:Function):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				if(opList.indexOf(codeList[i][0]) >= 0){
					handler(codeList, i);
				}
			}
		}
		
		private function optimizeConditionJump(codeList:Array, index:int):void
		{
			var code:Array = codeList[index];
			var jumpToCode:Array = codeList[index+code[1]];
			if(jumpToCode != null && jumpToCode[0] == OpCode.JUMP){
				code[1] += jumpToCode[1];
			}
		}
		
		private function optimizeJump(codeList:Array, index:int):void
		{
			var realCount:int = getFinalJumpCount(codeList, index);
			var code:Array = codeList[index];
			if(code[1] != realCount){
				code[1] = realCount;
			}
		}
		
		private function getFinalJumpCount(codeList:Array, index:int):int
		{
			stack.length = 0;
			var count:int = 0;
			for(;;){
				var code:Array = codeList[index+count];
				if(code == null || code[0] != OpCode.JUMP){
					break;
				}
				if(code[1] == 0){
					return 0;
				}
				count += code[1];
				if(stack.indexOf(count) >= 0){
					return 0;
				}
				stack.push(count);
			}
			return count;
		}
	}
}