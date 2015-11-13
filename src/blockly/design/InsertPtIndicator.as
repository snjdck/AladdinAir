package blockly.design
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;

	public class InsertPtIndicator extends Shape
	{
		static public const RECT_H:int = 4;
		
		private var drawer:BlockDrawer;
		
		public function InsertPtIndicator()
		{
			drawer = new BlockDrawer(graphics);
		}
		
		public function clear():void
		{
			graphics.clear();
		}
		
		public function indicate(dragTarget:BlockBase, insertPt:InsertPtInfo):void
		{
			clear();
			if(null == insertPt){
				return;
			}
			var block:BlockBase = insertPt.block;
			switch(insertPt.type){
				case BlockBase.INSERT_PT_ABOVE:
					var dragTargetTotalHeight:int = dragTarget.getTotalBlockHeight();
					beginDrawOutline(block.x, block.y - dragTargetTotalHeight);
					drawer.drawStatement(dragTarget.getTotalBlockWidth(), dragTargetTotalHeight);
					break;
				case BlockBase.INSERT_PT_BELOW:
					if(null == block.nextBlock){
						beginDrawOutline(block.x, block.y + block.getBlockHeight());
						drawer.drawStatement(dragTarget.getTotalBlockWidth(), dragTarget.getTotalBlockHeight());
					}else{
						drawRect(block.x, block.y + block.getBlockHeight(), block.getBlockWidth());
					}
					break;
				case BlockBase.INSERT_PT_CHILD:
					var child:DisplayObject = (block as MyBlock).getArgBlockAt(insertPt.index);
					if(child is BlockArg){
						drawRect(child.x+block.x, child.y+block.y, 20);
					}else{
						drawRect(child.x, child.y, 20);
					}
					break;
				case BlockBase.INSERT_PT_SUB:
					drawRect(block.x + BlockDrawer.armW, block.y + block.getPositionSub(insertPt.index), block.getBlockWidth());
					break;
				case BlockBase.INSERT_PT_WRAP:
					beginDrawOutline(
						block.x - BlockDrawer.armW,
						block.y - dragTarget.getPositionSub(insertPt.index)
					);
					if(!dragTarget.hasSubBlock2()){
						drawer.drawFor(dragTarget.getBlockWidth(), dragTarget.getPositionSub1(), block.getTotalBlockHeight());
					}else if(0 == insertPt.index){
						drawer.drawIfElse(dragTarget.getBlockWidth(), dragTarget.getPositionSub1(), block.getTotalBlockHeight(), dragTarget.getSub2Height());
					}else{
						drawer.drawIfElse(dragTarget.getBlockWidth(), dragTarget.getPositionSub1(), dragTarget.getSub1Height(), block.getTotalBlockHeight());
					}
					break;
			}
		}
		
		private function drawRect(px:Number, py:Number, w:Number):void
		{
			var g:Graphics = graphics;
			g.beginFill(0xFF);
			g.drawRect(px, py, w, RECT_H);
			g.endFill();
		}
		
		private function beginDrawOutline(offsetX:int, offsetY:int):void
		{
			graphics.lineStyle(2, 0xFF);
			drawer.setOffset(offsetX, offsetY);
		}
	}
}