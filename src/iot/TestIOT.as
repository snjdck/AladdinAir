package iot
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class TestIOT extends Sprite
	{
		private var boxList:Array = [];
		private var linkList:Array = [];
		
		public function TestIOT()
		{
			var a:Box = new Box();
			addChild(a);
			
			a.x = 100;
			a.y = 100;
			
			
			var b:Box = new Box();
			addChild(b);
			
			b.x = 400;
			b.y = 300;
			
			boxList.push(a, b);
			for each(var item:Box in boxList){
				item.addPtListener(__onMouseDown, __onMouseDown);
				item.addEventListener(MouseEvent.MOUSE_DOWN, __onDrag);
			}
		}
		
		private var dragBox:Box;
		
		private function __onDrag(evt:MouseEvent):void
		{
			dragBox = evt.currentTarget as Box;
			stage.addEventListener(MouseEvent.MOUSE_UP, __onDrop);
			stage.addEventListener(Event.ENTER_FRAME, __updateLinker);
			dragBox.startDrag();
		}
		
		private function __updateLinker(event:Event):void
		{
			for each(var linker:PtLinker in linkList){
				linker.redraw();
			}
		}
		
		private function __onDrop(evt:MouseEvent):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, __updateLinker);
			stage.removeEventListener(MouseEvent.MOUSE_UP, __onDrop);
			dragBox.stopDrag();
		}
		
		private var dragFlag:Boolean;
		private var dragTarget:CirclePoint;
		private var dropTarget:CirclePoint;
		
		private function __onMouseDown(evt:MouseEvent):void
		{
			evt.stopPropagation();
			dragTarget = evt.target as CirclePoint;
			
			dragFlag = true;
			var dragBox:Box = dragTarget.parent as Box;
			stage.addEventListener(Event.ENTER_FRAME, __onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			for each(var item:Box in boxList){
				item.hidePt(dragTarget);
			}
		}
		
		private function __onMouseUp(evt:MouseEvent):void
		{
			if(dropTarget != null){
				var linker:PtLinker = new PtLinker(dragTarget, dropTarget);
				linkList.push(linker);
				addChild(linker);
			}
			graphics.clear();
			
			dragFlag = false;
			dragTarget = null;
			stage.removeEventListener(Event.ENTER_FRAME, __onEnterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			for each(var item:Box in boxList){
				item.showPt();
			}
		}
		
		private function __onEnterFrame(evt:Event):void
		{
			dropTarget = null;
			var fromX:Number = dragTarget.globalX;
			var fromY:Number = dragTarget.globalY;
			
			var centerX:Number = (mouseX - fromX) * 0.5;
			var centerY:Number = (mouseY - fromY) * 0.5;
			
			graphics.clear();
			graphics.lineStyle(1);
			
			
			var item:Box;
			if(dragTarget.isIn){
				for each(item in boxList){
					for each(var ptOut:CirclePoint in item.ptListOut){
						if(ptOut.visible && ptOut.hitTestPoint(mouseX, mouseY, true)){
							dropTarget = ptOut;
						}
					}
				}
			}else{
				for each(item in boxList){
					for each(var ptIn:CirclePoint in item.ptListIn){
						if(ptIn.visible &&　ptIn.hitTestPoint(mouseX, mouseY, true)){
							dropTarget = ptIn;
						}
					}
				}
			}
			
			graphics.moveTo(fromX, fromY);
			if(dropTarget != null){
				graphics.lineTo(dropTarget.globalX, dropTarget.globalY);
			}else{
				graphics.lineTo(mouseX, mouseY);
			}
		}
	}
}