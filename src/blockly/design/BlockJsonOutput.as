package blockly.design
{
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
				return outputCodeSelf(argBlock);
			}
			var value:String = block.defaultArgBlockList[index].text;
			return {"type":"string", "value":value};
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
					return {"type":"break"};
				case BlockBase.BLOCK_TYPE_CONTINUE:
					return {"type":"continue"};
				case BlockBase.BLOCK_TYPE_EXPRESSION:
				case BlockBase.BLOCK_TYPE_STATEMENT:
					return {
						"type":"function",
						"method":block.cmd,
						"argList":collectArgs(block)
					};
				case BlockBase.BLOCK_TYPE_FOR:
					return {
						"type":"while",
						"condition":outputArg(block, 0),
						"loop":outputCodeAll(block.subBlock1)
					};
				case BlockBase.BLOCK_TYPE_IF:
					return {
						"type":"if",
						"condition":outputArg(block, 0),
						"code":outputCodeAll(block.subBlock1),
						"caseTrue":outputCodeAll(block.subBlock1),
						"caseFalse":outputCodeAll(block.subBlock2)
					};
				case BlockBase.BLOCK_TYPE_ELSE_IF:
					return {
						"type":"else if",
						"condition":outputArg(block, 0),
						"code":outputCodeAll(block.subBlock1)
					};
				case BlockBase.BLOCK_TYPE_ELSE:
					return {
						"type":"else",
						"code":outputCodeAll(block.subBlock1)
					};
			}
			return null;
		}
	}
}