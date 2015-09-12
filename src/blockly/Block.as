package blockly
{
	import flash.display.Graphics;

	public class Block
	{
		static private const t1:int = 4;
		
		static private const t2:int = 10;
		static private const t3:int = 20;
		
		public var isStatement:Boolean;
		public var isFunction:Boolean;
		
		public var inputCount:int = 0;
		
		public var innerInput:BlockShape;
		public var color:uint = 0xFF00;
		
		public function Block()
		{
		}
		
		public function draw(g:Graphics, x:Number, y:Number, w:Number, h:Number):void
		{
			g.beginFill(color);
			drawPath(g, x, y, w, h);
//			if(innerInput){
//				innerInput.x = 
//				innerInput.draw(g, x+30, y+30, 50, 50);
//			}
		}
		
		internal function drawPath(g:Graphics, x:Number, y:Number, w:Number, h:Number):void
		{
			g.moveTo(x+t1, y);
			
			if(!isStatement){
				g.lineTo(x+20, y);
				g.lineTo(x+30, y+5);
				g.lineTo(x+40, y);
			}
			
			g.lineTo(x+w-t1, y);
			g.lineTo(x+w, y+t1);
			
			for(var i:int=0; i<inputCount; ++i){
				drawInput(g, x+w, y+50+i*30);
			}
			
			g.lineTo(x+w, y+h-t1);
			g.lineTo(x+w-t1, y+h);
			
			if(!isStatement){
				g.lineTo(x+40, y+h);
				g.lineTo(x+30, y+h+5);
				g.lineTo(x+20, y+h);
			}
			
			g.lineTo(x+t1, y+h);
			g.lineTo(x, y+h-t1);
			
			if(isStatement){
				g.lineTo(x, y+t3);
				g.lineTo(x-10, y+t3+5);
				g.lineTo(x-10, y+t2-5);
				g.lineTo(x, y+t2);
			}
			
			g.lineTo(x, y+t1);
			g.lineTo(x+t1, y);
			
			
			if(innerInput){
				innerInput.block.drawPath(g, x+30, y+30, 50, 50);
			}
		}
		
		private function drawInput(g:Graphics, px:Number, py:Number):void
		{
			g.lineTo(px, py);
			
			g.lineTo(px-10, py-5);
			g.lineTo(px-10, py+10+5);
			
			g.lineTo(px, py+10);
		}
	}
}