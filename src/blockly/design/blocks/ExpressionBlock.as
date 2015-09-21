package blockly.design.blocks
{
	import flash.display.Graphics;
	import blockly.design.MyBlock;

	public class ExpressionBlock extends MyBlock
	{
		public function ExpressionBlock()
		{
			isExpression = true;
		}
		
		override protected function drawBg(w:int, h:int):void
		{
			var g:Graphics = graphics;
//			g.lineStyle(0);
			g.beginFill(0xFF00);
			w += gapX * 2;
			if(w < h){
				w = h;
			}
			g.drawRoundRect(gapX, 0, w, h, h, h);
			g.endFill();
		}
	}
}