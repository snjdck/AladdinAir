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
		public var outPt:CirclePointOut;
		public var inPt:CirclePointIn;
		
		public function PtLinker(from:CirclePoint, to:CirclePoint)
		{
			var g:Graphics = graphics;
			g.lineStyle(10, 0, 0);
			g.moveTo(from.globalX, from.globalY);
			g.lineTo(to.globalX, to.globalY);
			g.lineStyle(2, 0xFF00);
			g.moveTo(from.globalX, from.globalY);
			g.lineTo(to.globalX, to.globalY);
			
			if(from is CirclePointOut){
				outPt = from as CirclePointOut;
				inPt = to as CirclePointIn;
			}else{
				outPt = to as CirclePointOut;
				inPt = from as CirclePointIn;
			}
			
			outPt.addInPt(inPt);
			inPt.linkedOutPt = outPt;
			
//			addEventListener(MouseEvent.RIGHT_CLICK, __onRightClick);
			
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			menu.customItems = [new ContextMenuItem("delete line")];
			for each(var item:ContextMenuItem in menu.customItems){
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, __onMenuSelect);
			}
	
			contextMenu = menu;
		}
		
		private function __onMenuSelect(evt:ContextMenuEvent):void
		{
			var item:ContextMenuItem = evt.target as ContextMenuItem;
			if(item.caption == "delete line"){
				parent.removeChild(this);
				outPt.removePt(inPt);
				inPt.linkedOutPt = null;
			}
		}
		
		private function __onRightClick(evt:MouseEvent):void
		{
			trace("ctx");
		}
	}
}