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
			block.notifyChildChanged();
		}
		
		private function insertStatement(target:BlockBase):void
		{
			switch(type){
				case BlockBase.INSERT_PT_BELOW:
					target.addBlockToLast(block.nextBlock);
					target.prevBlock = block;
					block.layoutAfterInsertBelow();
					var topParent:BlockBase = block.topBlock.parentBlock;
					if(topParent != null){
						topParent.redrawControlBlockRecursively();
					}
					break;
				case BlockBase.INSERT_PT_ABOVE:
					target.prevBlock = block.prevBlock;
					target.addBlockToLast(block);
					block.layoutAfterInsertAbove();
					break;
				case BlockBase.INSERT_PT_SUB:
					if(0 == index){
						target.addBlockToLast(block.subBlock1);
						block.subBlock1 = target;
					}else{
						target.addBlockToLast(block.subBlock2);
						block.subBlock2 = target;
					}
					block.redrawControlBlockRecursively();
					break;
				case BlockBase.INSERT_PT_WRAP:
					if(0 == index){
						target.subBlock1 = block;
						target.setPositionBySub1(block);
					}else{
						target.subBlock2 = block;
						target.setPositionBySub2(block);
					}
					target.layoutChildren();
					target.drawBg();
					target.layoutAfterInsertBelow();
					break;
			}
		}
	}
}