package blockly.runtime
{
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class AssemblyOptimizer
	{
		public function AssemblyOptimizer()
		{
		}
		
		public function optimize(codeList:Array):void
		{
			runPass(codeList, OpCode.JUMP_IF_TRUE, optimizeConstCondition);
			runPass(codeList, OpCode.JUMP, optimizeJump);
			runPass(codeList, OpCode.JUMP_IF_TRUE, optimizeJumpIfTrue);
		}
		
		private function runPass(codeList:Array, op:String, handler:Function):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code != null && code[0] == op){
					handler(codeList, i);
				}
			}
		}
		
		private function optimizeConstCondition(codeList:Array, index:int):void
		{
			var prevCode:Array = codeList[index-1];
			if(prevCode[0] != OpCode.PUSH){
				return;
			}
			var jumpCount:int = Boolean(prevCode[1]) ? (codeList[index][1] + 1) : 2;
			codeList[index-1] = OpFactory.Jump(jumpCount);
			codeList[index] = null;
		}
		
		private function optimizeJumpIfTrue(codeList:Array, index:int):void
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
			var count:int = codeList[index][1];
			if(0 == count){
				return 0;
			}
			var nextIndex:int = index + count;
			if(nextIndex >= codeList.length || codeList[nextIndex][0] != OpCode.JUMP){
				return count;
			}
			return count + getFinalJumpCount(codeList, nextIndex);
		}
	}
}