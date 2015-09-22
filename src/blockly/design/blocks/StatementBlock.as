package blockly.design.blocks
{
	import flash.display.Graphics;
	
	import blockly.design.BlockDrawer;
	import blockly.design.MyBlock;

	public class StatementBlock extends MyBlock
	{
		public function StatementBlock()
		{
			isExpression = false;
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