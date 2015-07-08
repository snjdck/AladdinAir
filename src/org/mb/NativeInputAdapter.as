package org.mb
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;

	public class NativeInputAdapter
	{
		private var stage:Stage;
		private var touchMgr:TouchManager;
		
		public function NativeInputAdapter(stage:Stage, touchMgr:TouchManager)
		{
			this.stage = stage;
			this.touchMgr = touchMgr;
			init();
		}
		
		private function init():void
		{
			if(Multitouch.supportsTouchEvents){
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				stage.addEventListener(TouchEvent.TOUCH_BEGIN, __onTouchBegin);
				stage.addEventListener(TouchEvent.TOUCH_MOVE, __onTouchMove);
				stage.addEventListener(TouchEvent.TOUCH_END, __onTouchEnd);
			}else{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, __onMouseDown);
			}
		}
		
		private function __onMouseDown(evt:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			
			touchMgr.onTouchBegin(0, evt.stageX, evt.stageY, getTimer());
		}
		
		private function __onMouseMove(evt:MouseEvent):void
		{
			touchMgr.onTouchMove(0, evt.stageX, evt.stageY, getTimer());
		}
		
		private function __onMouseUp(evt:MouseEvent):void
		{
			touchMgr.onTouchEnd(0, evt.stageX, evt.stageY, getTimer());
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
		}
		
		private function __onTouchBegin(evt:TouchEvent):void
		{
			touchMgr.onTouchBegin(evt.touchPointID, evt.stageX, evt.stageY, evt.timestamp);
		}
		
		private function __onTouchMove(evt:TouchEvent):void
		{
			touchMgr.onTouchMove(evt.touchPointID, evt.stageX, evt.stageY, evt.timestamp);
		}
		
		private function __onTouchEnd(evt:TouchEvent):void
		{
			if(evt.isTouchPointCanceled){
				touchMgr.onTouchCancel(evt.touchPointID, evt.stageX, evt.stageY, evt.timestamp);
			}else{
				touchMgr.onTouchEnd(evt.touchPointID, evt.stageX, evt.stageY, evt.timestamp);
			}
		}
	}
}