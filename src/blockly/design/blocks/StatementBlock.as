package blockly.design.blocks
{
	import flash.display.Graphics;
	import blockly.design.MyBlock;

	public class StatementBlock extends MyBlock
	{
		public function StatementBlock()
		{
			isExpression = false;
		}
		
		override protected function drawBg(w:int, h:int):void
		{
			var a:int = 10;
			var b:int = 4;
			var len:int = 20;
			
			var g:Graphics = graphics;
//			g.lineStyle(0);
			g.beginFill(0xFF00);
			
			g.moveTo(gapX, 0);
			g.lineTo(a, 0);
			g.lineTo(a, b);
			g.lineTo(a+len, b);
			g.lineTo(a+len, 0);
			g.lineTo(w, 0);
			g.lineTo(w, h);
			g.lineTo(a+len, h);
			g.lineTo(a+len, h+b);
			g.lineTo(a, h+b);
			g.lineTo(a, h);
			g.lineTo(gapX, h);
			g.lineTo(gapX, 0);
			
			g.endFill();
		}
	}
}