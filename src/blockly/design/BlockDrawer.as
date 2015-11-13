package blockly.design
{
	import flash.display.Graphics;

	public class BlockDrawer
	{
		static public var gapX:int = 2;
		static public var a:int = 10;
		static public var b:int = 4;
		static public var len:int = 20;
		
		static public var armW:int = 10;
		static public var armH:int = 10;
		
		private var g:Graphics;
		
		private var offsetX:int;
		private var offsetY:int;
		
		public function BlockDrawer(g:Graphics)
		{
			this.g = g;
		}
		
		public function setOffset(vx:int, vy:int):void
		{
			offsetX = vx;
			offsetY = vy;
		}
		
		public function drawExpression(w:int, h:int):void
		{
			w = Math.max(w + 4, h);
			g.drawRoundRect(2, 0, w, h, h, h);
		}
		
		public function drawStatement(w:int, h:int, hasNext:Boolean=true):void
		{
			w = Math.max(w, 60);
			drawTop(w);
			lineTo(w, h);
			if(hasNext){
				drawBottom(h, gapX);
			}else{
				lineTo(gapX, h);
			}
			lineTo(gapX, 0);
		}
		
		public function drawFor(w:int, h:int, childHeight:int):void
		{
			var y1:int = h+childHeight+armH;
			
			drawTop(w);
			lineTo(w, h);
			drawMiddle(h, w-armW, childHeight);
			lineTo(w, y1);
			drawBottom(y1, gapX);
			lineTo(gapX, 0);
		}
		
		public function drawIfElse(w:int, h:int, child1Height:int, child2Height:int):void
		{
			w = Math.max(w, 60);
			var y1:int = h+child1Height+armH;
			var y2:int = y1 + child2Height+armH;
			
			drawTop(w);
			lineTo(w, h);
			drawMiddle(h, w-armW, child1Height);
			lineTo(w, y1);
			drawMiddle(y1, w-armW, child2Height);
			lineTo(w, y2);
			drawBottom(y2, gapX);
			lineTo(gapX, 0);
		}
		
		private function drawTop(w:int):void
		{
			var x:int = gapX;
			moveTo(x,		0);
			lineTo(x + a,	0);
			lineTo(x + a,	b);
			lineTo(x + a + len, b);
			lineTo(x + a + len, 0);
			lineTo(w, 0);
		}
		
		private function drawBottom(y:int, endX:int):void
		{
			lineTo(endX + a + len, y);
			lineTo(endX + a + len, y + b);
			lineTo(endX + a, y + b);
			lineTo(endX + a, y);
			lineTo(endX, y);
		}
		
		private function drawMiddle(y:int, w:int, h:int):void
		{
			drawBottom(y, armW);
			lineTo(armW, y + h);
			lineTo(armW + w, y + h);
		}
		
		private function moveTo(px:int, py:int):void
		{
			g.moveTo(offsetX + px, offsetY + py);
		}
		
		private function lineTo(px:int, py:int):void
		{
			g.lineTo(offsetX + px, offsetY + py);
		}
	}
}