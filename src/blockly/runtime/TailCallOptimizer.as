package blockly.runtime
{
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class TailCallOptimizer
	{
		public function TailCallOptimizer()
		{
		}
		
		public function optimize(codeList:Array):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.RETURN){
					continue;
				}
				var prevIndex:int = i - 1;
				var prevCode:Array = codeList[prevIndex];
				if(prevCode[0] != OpCode.INVOKE){
					continue;
				}
				codeList[prevIndex] = OpFactory.Jump(prevCode[1]);
			}
		}
	}
}