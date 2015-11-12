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
			g.lineTo(offsetX + w, offsetY + h);
			if(hasNext){
				drawBottom(h, gapX);
			}else{
				g.lineTo(offsetX + gapX, offsetY + h);
			}
			g.lineTo(offsetX + gapX, offsetY);
		}
		
		public function drawFor(w:int, h:int, childHeight:int):void
		{
			var y1:int = h+childHeight+armH;
			
			drawTop(w);
			g.lineTo(offsetX + w, offsetY + h);
			drawMiddle(h, w-armW, childHeight);
			g.lineTo(offsetX + w, offsetY + y1);
			drawBottom(y1, gapX);
			g.lineTo(offsetX + gapX, offsetY);
		}
		
		public function drawIfElse(w:int, h:int, child1Height:int, child2Height:int):void
		{
			w = Math.max(w, 60);
			var y1:int = h+child1Height+armH;
			var y2:int = y1 + child2Height+armH;
			
			drawTop(w);
			g.lineTo(offsetX + w, offsetY + h);
			drawMiddle(h, w-armW, child1Height);
			g.lineTo(offsetX + w, offsetY + y1);
			drawMiddle(y1, w-armW, child2Height);
			g.lineTo(offsetX + w, offsetY + y2);
			drawBottom(y2, gapX);
			g.lineTo(offsetX + gapX, offsetY);
		}
		
		private function drawTop(w:int):void
		{
			var x:int = offsetX + gapX;
			g.moveTo(x,		offsetY);
			g.lineTo(x + a,	offsetY);
			g.lineTo(x + a,	offsetY + b);
			g.lineTo(x + a + len, offsetY + b);
			g.lineTo(x + a + len, offsetY);
			g.lineTo(offsetX + w, offsetY);
		}
		
		private function drawBottom(y:int, endX:int):void
		{
			endX += offsetX;
			y += offsetY;
			g.lineTo(endX + a + len, y);
			g.lineTo(endX + a + len, y + b);
			g.lineTo(endX + a, y + b);
			g.lineTo(endX + a, y);
			g.lineTo(endX, y);
		}
		
		private function drawMiddle(y:int, w:int, h:int):void
		{
			drawBottom(y, armW);
			y += offsetY + h;
			g.lineTo(offsetX + armW, y);
			g.lineTo(offsetX + armW + w, y);
		}
	}
}