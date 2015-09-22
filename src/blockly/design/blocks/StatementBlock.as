package blockly.design.blocks
{
	import flash.display.Graphics;
	
	import blockly.design.BlockBase;
	import blockly.design.BlockDrawer;
	import blockly.design.MyBlock;

	public class StatementBlock extends MyBlock
	{
		public function StatementBlock()
		{
			type = BlockBase.BLOCK_TYPE_STATEMENT;
		}
		
		override protected function drawBg(w:int, h:int):void
		{
			var g:Graphics = graphics;
			g.beginFill(0xFF00);
			BlockDrawer.draw(graphics, w, h);
			g.endFill();
		}
	}
}