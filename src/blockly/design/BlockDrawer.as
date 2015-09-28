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
		
		static public function drawExpression(g:Graphics, w:int, h:int):void
		{
			w += 4;
			if(w < h){
				w = h;
			}
			g.drawRoundRect(2, 0, w, h, h, h);
		}
		
		static public function drawStatement(g:Graphics, w:int, h:int, hasNext:Boolean=true):void
		{
			w = Math.max(w, 60);
			drawTop(g, w);
			g.lineTo(w, h);
			if(hasNext){
				drawBottom(g, h, gapX);
			}else{
				g.lineTo(gapX, h);
			}
			g.lineTo(gapX, 0);
		}
		
		static public function drawFor(g:Graphics, w:int, h:int, childHeight:int):void
		{
			var y1:int = h+childHeight+armH;
			
			drawTop(g, w);
			g.lineTo(w, h);
			drawMiddle(g, h, w-armW, childHeight);
			g.lineTo(w, y1);
			drawBottom(g, y1, gapX);
			g.lineTo(gapX, 0);
		}
		
		static public function drawIfElse(g:Graphics, w:int, h:int, child1Height:int, child2Height:int):void
		{
			w = Math.max(w, 60);
			var y1:int = h+child1Height+armH;
			var y2:int = y1 + child2Height+armH;
			
			drawTop(g, w);
			g.lineTo(w, h);
			drawMiddle(g, h, w-armW, child1Height);
			g.lineTo(w, y1);
			drawMiddle(g, y1, w-armW, child2Height);
			g.lineTo(w, y2);
			drawBottom(g, y2, gapX);
			g.lineTo(gapX, 0);
		}
		
		static private function drawTop(g:Graphics, w:int):void
		{
			g.moveTo(gapX, 0);
			g.lineTo(gapX+a, 0);
			g.lineTo(gapX+a, b);
			g.lineTo(gapX+a+len, b);
			g.lineTo(gapX+a+len, 0);
			g.lineTo(w, 0);
		}
		
		static private function drawBottom(g:Graphics, y:int, endX:int):void
		{
			g.lineTo(endX+a+len, y);
			g.lineTo(endX+a+len, y+b);
			g.lineTo(endX+a, y+b);
			g.lineTo(endX+a, y);
			g.lineTo(endX, y);
		}
		
		static private function drawMiddle(g:Graphics, y:int, w:int, h:int):void
		{
			drawBottom(g, y, armW);
			g.lineTo(armW, y + h);
			g.lineTo(armW + w, y + h);
		}
	}
}