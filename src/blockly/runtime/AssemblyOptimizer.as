package blockly.runtime
{
	import blockly.OpCode;

	internal class AssemblyOptimizer
	{
		private const newJumpIndex:Vector.<int> = new Vector.<int>();
		private const jumpStack:Vector.<int> = new Vector.<int>();
		
		public function AssemblyOptimizer(){}
		
		public function optimize(codeList:Array):void
		{
			newJumpIndex.length = codeList.length;
			runPass(codeList, OpCode.JUMP, calcNewJumpIndex);
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
		
		private function optimizeJumpIfTrue(codeList:Array, index:int):void
		{
			var code:Array = codeList[index];
			var jumpToCode:Array = codeList[index+code[1]];
			if(jumpToCode != null && jumpToCode[0] == OpCode.JUMP){
				code[1] += jumpToCode[1];
			}
		}
		
		private function calcNewJumpIndex(codeList:Array, index:int):void
		{
			newJumpIndex[index] = getFinalJumpCount(codeList, index);
			jumpStack.length = 0;
		}
		
		private function optimizeJump(codeList:Array, index:int):void
		{
			var realCount:int = newJumpIndex[index];
			var code:Array = codeList[index];
			if(code[1] != realCount){
				code[1] = realCount;
			}
		}
		
		private function getFinalJumpCount(codeList:Array, index:int):int
		{
			if(jumpStack.indexOf(index) >= 0){
				return 0;
			}
			jumpStack.push(index);
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