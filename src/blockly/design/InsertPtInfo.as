package blockly.design
{
	public class InsertPtInfo
	{
		public var block:BlockBase;
		public var type:int;
		public var index:int;
		
		public function InsertPtInfo(block:BlockBase, type:int, index:int=0)
		{
			this.block = block;
			this.type = type;
			this.index = index;
		}
		
		public function insert(target:BlockBase):void
		{
			if(target.isExpression()){
				insertExpression(target);
			}else{
				insertStatement(target);
			}
		}
		
		private function insertExpression(target:BlockBase):void
		{
			block.setChildBlockAt(target, index);
			block.layoutChildren();
			block.drawBg();
		}
		
		private function insertStatement(target:BlockBase):void
		{
			switch(type){
				case BlockBase.INSERT_PT_BELOW:
					target.addBlockToLast(block.nextBlock);
					target.prevBlock = block;
					block.layoutAfterInsertBelow();
					if(block.topBlock.parentBlock != null){
						block.topBlock.parentBlock.adjustSubBlock1Change();
					}
					break;
				case BlockBase.INSERT_PT_ABOVE:
					target.prevBlock = block.prevBlock;
					target.addBlockToLast(block);
					block.layoutAfterInsertAbove();
					break;
				case BlockBase.INSERT_PT_SUB1:
					block.subBlock1 = target;
					block.relayout();
					block.drawBg();
					break;
				case BlockBase.INSERT_PT_SUB2:
					block.subBlock2 = target;
					block.relayout();
					block.drawBg();
					break;
			}
		}
	}
}