package blockly.design
{
	import blockly.SyntaxTreeFactory;

	public class BlockJsonOutput
	{
		public function BlockJsonOutput()
		{
		}
		
		private function collectArgs(block:BlockBase):Array
		{
			var n:int = block.defaultArgBlockList.length;
			var argList:Array = [];
			for(var i:int=0; i<n; ++i){
				argList[i] = outputArg(block, i);
			}
			return argList;
		}
		
		private function outputArg(block:BlockBase, index:int):Object
		{
			var argBlock:BlockBase = block.argBlockList[index];
			if(argBlock != null){
				return SyntaxTreeFactory.NewExpression(argBlock.cmd, collectArgs(argBlock));
			}
			var value:String = block.defaultArgBlockList[index].text;
			return SyntaxTreeFactory.NewString(value);
		}
		
		public function outputCodeAll(block:BlockBase):Array
		{
			if(null == block){
				return null;
			}
			var result:Array = [];
			while(block != null){
				result.push(outputCodeSelf(block));
				block = block.nextBlock;
			}
			return result;
		}
		
		public function outputCodeSelf(block:BlockBase):Object
		{
			switch(block.type){
				case BlockBase.BLOCK_TYPE_BREAK:
					return SyntaxTreeFactory.Break();
				case BlockBase.BLOCK_TYPE_CONTINUE:
					return SyntaxTreeFactory.Continue();
				case BlockBase.BLOCK_TYPE_STATEMENT:
					return SyntaxTreeFactory.NewStatement(block.cmd, collectArgs(block));
				case BlockBase.BLOCK_TYPE_FOR:
					return SyntaxTreeFactory.NewWhile(outputArg(block, 0), outputCodeAll(block.subBlock1));
				case BlockBase.BLOCK_TYPE_IF:
					return SyntaxTreeFactory.NewIf(outputArg(block, 0), outputCodeAll(block.subBlock1));
				case BlockBase.BLOCK_TYPE_ELSE_IF:
					return SyntaxTreeFactory.NewElseIf(outputArg(block, 0), outputCodeAll(block.subBlock1));
				case BlockBase.BLOCK_TYPE_ELSE:
					return SyntaxTreeFactory.NewElse(outputCodeAll(block.subBlock1));
				case BlockBase.BLOCK_TYPE_ARDUINO:
					return {
						"type":"arduino",
						"setup":outputCodeAll(block.subBlock1),
						"loop":outputCodeAll(block.subBlock2)
					};
			}
			return null;
		}
	}
}