package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class Box extends Sprite
	{
		public var pIn:CirclePoint;
		public var pOut:CirclePoint;
		
		public function Box()
		{
			var g:Graphics = graphics;
			g.beginFill(0xcccccc);
			g.drawRect(0,0,100,80);
			g.endFill();
			
			pIn = addPt(40, true);
			pOut = addPt(40, false);
		}
		
		public function addOutLinker():void
		{
			
		}
		
		public function addInLinker():void
		{
			
		}
		
		public function hidePt(isIn:Boolean):void
		{
			if(isIn){
				pIn.visible = false;
			}else{
				pOut.visible = false;
			}
		}
		
		public function showPt():void
		{
			pIn.visible = true;
			pOut.visible = true;
		}
		
		public function addPtListener(inHandler:Function, outHandler:Function):void
		{
			pIn.addEventListener(MouseEvent.MOUSE_DOWN, inHandler);
			pOut.addEventListener(MouseEvent.MOUSE_DOWN, outHandler);
		}
		
		private function addPt(py:int, isIn:Boolean):CirclePoint
		{
			var pt:CirclePoint = new CirclePoint(isIn);
			pt.y = py;
			addChild(pt);
			var g:Graphics = graphics;
			g.lineStyle(2);
			if(isIn){
				g.moveTo(20, py);
				g.lineTo(-20, py);
				pt.x = -20;
			}else{
				g.moveTo(80, py);
				g.lineTo(120, py);
				pt.x = 120;
			}
			return pt;
		}
	}
}