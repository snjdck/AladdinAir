package blockly.design.blocks
{
	import flash.display.Graphics;
	
	import blockly.design.BlockDrawer;
	import blockly.design.MyBlock;
	
	public class ForBlock extends MyBlock
	{
		public function ForBlock()
		{
		}
		
		override protected function drawBg(w:int, h:int):void
		{
			var g:Graphics = graphics;
			g.beginFill(0xFF00);
			BlockDrawer.drawFor(graphics, w, h);
			g.endFill();
		}
	}
}