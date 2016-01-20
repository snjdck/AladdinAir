package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class Box extends Sprite
	{
		public const ptListIn:Vector.<CirclePoint> = new Vector.<CirclePoint>();
		public const ptListOut:Vector.<CirclePoint> = new Vector.<CirclePoint>();
//		public var pIn:CirclePointIn;
//		public var pOut:CirclePointOut;
		
		public function Box()
		{
			var g:Graphics = graphics;
			g.beginFill(0xcccccc);
			g.drawRect(0,0,100,80);
			g.endFill();
			
			addInPt(addPt(40, true));
			addOutPt(addPt(40, false));
		}
		
		public function addInPt(ptIn:CirclePoint):void
		{
			ptListIn.push(ptIn);
		}
		
		public function addOutPt(ptOut:CirclePoint):void
		{
			ptListOut.push(ptOut);
		}
		
		public function addOutLinker():void
		{
			
		}
		
		public function addInLinker():void
		{
			
		}
		
		public function hideSelf(dragPt:CirclePoint):void
		{
			for each(var ptIn:CirclePoint in ptListIn){
				if(dragPt != ptIn){
					ptIn.visible = false;
				}
			}
			for each(var ptOut:CirclePoint in ptListOut){
				if(dragPt != ptOut){
					ptOut.visible = false;
				}
			}
		}
		
		public function hidePt(dragPt:CirclePoint):void
		{
			for each(var ptIn:CirclePoint in ptListIn){
				if(dragPt.isIn || ptIn.hasPt(dragPt)){
					ptIn.visible = false;
				}
			}
			for each(var ptOut:CirclePoint in ptListOut){
				if(!dragPt.isIn || ptOut.hasPt(dragPt)){
					ptOut.visible = false;
				}
			}
		}
		
		public function showPt():void
		{
			for each(var ptIn:CirclePoint in ptListIn){
				ptIn.visible = true;
			}
			for each(var ptOut:CirclePoint in ptListOut){
				ptOut.visible = true;
			}
		}
		
		public function addPtListener(inHandler:Function, outHandler:Function):void
		{
			for each(var ptIn:CirclePoint in ptListIn){
				ptIn.addEventListener(MouseEvent.MOUSE_DOWN, inHandler);
			}
			for each(var ptOut:CirclePoint in ptListOut){
				ptOut.addEventListener(MouseEvent.MOUSE_DOWN, outHandler);
			}
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