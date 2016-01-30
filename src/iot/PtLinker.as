package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class PtLinker extends Sprite
	{
		public var outPt:CirclePoint;
		public var inPt:CirclePoint;
		
		public function PtLinker(from:CirclePoint, to:CirclePoint)
		{
			/*
			var g:Graphics = graphics;
//			g.lineStyle(10, 0, 0);
			g.lineStyle(2, 0xFF00);
			
			var centerX:Number = (to.globalX + from.globalX) * 0.5;
			var centerY:Number = (to.globalY + from.globalY) * 0.5;
			if(from.isIn == from.globalX > to.globalX){
				g.moveTo(from.globalX, from.globalY);
				g.cubicCurveTo(centerX, from.globalY, centerX, to.globalY, to.globalX, to.globalY);
			}else{
				var dx:Number = (to.globalX - from.globalX) * 0.5;
				var dy:Number = (to.globalY - from.globalY) * 0.5;
				g.moveTo(from.globalX, from.globalY);
//				g.curveTo(from.globalX+dx, from.globalY, centerX, centerY);
				g.lineTo(to.globalX, to.globalY);
			}
			*/
			
			if(from.isIn){
				outPt = to;
				inPt = from;
			}else{
				outPt = from;
				inPt = to;
			}
			
			outPt.addPt(inPt);
			inPt.addPt(outPt);
			
			redraw();
			
//			addEventListener(MouseEvent.RIGHT_CLICK, __onRightClick);
			
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			menu.customItems = [new ContextMenuItem("delete line")];
			for each(var item:ContextMenuItem in menu.customItems){
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, __onMenuSelect);
			}
	
			contextMenu = menu;
		}
		
		public function redraw():void
		{
			var g:Graphics = graphics;
			g.clear();
			//			g.lineStyle(10, 0, 0);
			g.lineStyle(2, 0xFF00);
			
			var centerX:Number = (inPt.globalX + outPt.globalX) * 0.5;
			var centerY:Number = (inPt.globalY + outPt.globalY) * 0.5;
			if(outPt.globalX < inPt.globalX){
				g.moveTo(inPt.globalX, inPt.globalY);
				g.cubicCurveTo(centerX, inPt.globalY, centerX, outPt.globalY, outPt.globalX, outPt.globalY);
			}else{
//				var dx:Number = (to.globalX - from.globalX) * 0.5;
//				var dy:Number = (to.globalY - from.globalY) * 0.5;
				g.moveTo(inPt.globalX, inPt.globalY);
				//				g.curveTo(from.globalX+dx, from.globalY, centerX, centerY);
				g.lineTo(outPt.globalX, outPt.globalY);
			}
		}
		
		private function __onMenuSelect(evt:ContextMenuEvent):void
		{
			var item:ContextMenuItem = evt.target as ContextMenuItem;
			if(item.caption == "delete line"){
				parent.removeChild(this);
				outPt.removePt(inPt);
				inPt.removePt(outPt);
			}
		}
		
		private function __onRightClick(evt:MouseEvent):void
		{
			trace("ctx");
		}
	}
}