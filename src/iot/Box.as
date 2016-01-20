package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class Box extends Sprite
	{
		public const ptListIn:Vector.<CirclePointIn> = new Vector.<CirclePointIn>();
		public const ptListOut:Vector.<CirclePointOut> = new Vector.<CirclePointOut>();
//		public var pIn:CirclePointIn;
//		public var pOut:CirclePointOut;
		
		public function Box()
		{
			var g:Graphics = graphics;
			g.beginFill(0xcccccc);
			g.drawRect(0,0,100,80);
			g.endFill();
			
			addInPt(addPt(40, true) as CirclePointIn);
			addOutPt(addPt(40, false) as CirclePointOut);
		}
		
		public function addInPt(ptIn:CirclePointIn):void
		{
			ptListIn.push(ptIn);
		}
		
		public function addOutPt(ptOut:CirclePointOut):void
		{
			ptListOut.push(ptOut);
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
				for each(var ptIn:CirclePointIn in ptListIn){
					ptIn.visible = false;
				}
			}else{
				for each(var ptOut:CirclePointOut in ptListOut){
					ptOut.visible = false;
				}
			}
		}
		
		public function hideLinkedInPts():void
		{
			for each(var ptIn:CirclePointIn in ptListIn){
				if(ptIn.hasOutPt()){
					ptIn.visible = false;
				}
			}
		}
		
		public function showPt():void
		{
			for each(var ptIn:CirclePointIn in ptListIn){
				ptIn.visible = true;
			}
			for each(var ptOut:CirclePointOut in ptListOut){
				ptOut.visible = true;
			}
		}
		
		public function addPtListener(inHandler:Function, outHandler:Function):void
		{
			for each(var ptIn:CirclePointIn in ptListIn){
				ptIn.addEventListener(MouseEvent.MOUSE_DOWN, inHandler);
			}
			for each(var ptOut:CirclePointOut in ptListOut){
				ptOut.addEventListener(MouseEvent.MOUSE_DOWN, outHandler);
			}
		}
		
		private function addPt(py:int, isIn:Boolean):CirclePoint
		{
			var pt:CirclePoint = isIn ? new CirclePointIn() : new CirclePointOut();
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