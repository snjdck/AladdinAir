package blockly.design
{
	internal class InsertPtsFilter
	{
		public function InsertPtsFilter()
		{
		}
		
		public function filter(ptList:Array, blockType:int):Array
		{
			switch(blockType){
				case BlockBase.BLOCK_TYPE_ELSE_IF:
					return filterElseIf(ptList);
				case BlockBase.BLOCK_TYPE_ELSE:
					return filterElse(ptList);
			}
			return filterOthers(ptList);
		}
		
		private function filterElseIf(ptList:Array):Array
		{
			var result:Array = [];
			for each(var ptInfo:InsertPtInfo in ptList){
				if(ptInfo.type != BlockBase.INSERT_PT_BELOW){
					continue;
				}
				if(ptInfo.block.isIfBlock()){
					result.push(ptInfo);
				}
			}
			return result;
		}
		
		
		private function filterElse(ptList:Array):Array
		{
			var result:Array = [];
			for each(var ptInfo:InsertPtInfo in ptList){
				if(ptInfo.type != BlockBase.INSERT_PT_BELOW){
					continue;
				}
				var block:BlockBase = ptInfo.block;
				if(!block.isIfBlock()){
					continue;
				}
				block = block.nextBlock;
				if(block == null || !block.isElseBlock()){
					result.push(ptInfo);
				}
			}
			return result;
		}
		
		private function filterOthers(ptList:Array):Array
		{
			var result:Array = [];
			for each(var ptInfo:InsertPtInfo in ptList){
				if(ptInfo.type != BlockBase.INSERT_PT_BELOW){
					result.push(ptInfo);
					continue;
				}
				var block:BlockBase = ptInfo.block.nextBlock;
				if(block == null || !block.isElseBlock()){
					result.push(ptInfo);
				}
			}
			return result;
		}
	}
}