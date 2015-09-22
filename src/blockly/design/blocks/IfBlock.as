package blockly.design.blocks
{
	import flash.display.Graphics;
	
	import blockly.design.BlockDrawer;
	import blockly.design.MyBlock;
	
	public class IfBlock extends MyBlock
	{
		public function IfBlock()
		{
		}
		
		override protected function drawBg(w:int, h:int):void
		{
			var g:Graphics = graphics;
			g.beginFill(0xFF00);
			BlockDrawer.drawIfElse(graphics, w, h);
			g.endFill();
		}
	}
}