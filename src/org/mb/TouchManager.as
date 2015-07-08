package org.mb
{
	public class TouchManager
	{
		private const touchDict:Array = [];
		private var touchCount:int;
		
		private var gestureMgr:GestureManager;
		
		public function TouchManager(gestureMgr:GestureManager)
		{
			this.gestureMgr = gestureMgr;
		}
		
		public function onTouchBegin(touchID:int, stageX:Number, stageY:Number, timestamp:int):void
		{
			var touch:Touch = new Touch(touchID, stageX, stageY, timestamp);
			touchDict[touchID] = touch;
			++touchCount;
			gestureMgr.onTouchBegin(touch);
		}
		
		public function onTouchMove(touchID:int, stageX:Number, stageY:Number, timestamp:int):void
		{
			var touch:Touch = touchDict[touchID];
			if(touch.isLocationEqual(stageX, stageY)){
				return;
			}
			touch.update(stageX, stageY, timestamp);
			gestureMgr.onTouchMove(touch);
		}
		
		public function onTouchEnd(touchID:int, stageX:Number, stageY:Number, timestamp:int):void
		{
			var touch:Touch = touchDict[touchID];
			touch.update(stageX, stageY, timestamp);
			touchDict[touchID] = null;
			--touchCount;
			gestureMgr.onTouchEnd(touch);
		}
		
		public function onTouchCancel(touchID:int, stageX:Number, stageY:Number, timestamp:int):void
		{
			var touch:Touch = touchDict[touchID];
			touch.update(stageX, stageY, timestamp);
			touchDict[touchID] = null;
			--touchCount;
			gestureMgr.onTouchCancel(touch);
		}
	}
}