package org.mb
{
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.utils.getTimer;

	public class Touch
	{
		/*
		static public function CreateByTouchEvent(evt:TouchEvent):Touch
		{
			return new Touch(evt.touchPointID, evt.stageX, evt.stageY, evt.timestamp);
		}
		
		static public function CreateByMouseEvent(evt:MouseEvent):Touch
		{
			return new Touch(0, evt.stageX, evt.stageY, getTimer());
		}
		*/
		public var id:int;
		
		public var stageX:Number;
		public var stageY:Number;
		
		public var timestamp:int;
		
		public function Touch(id:int, stageX:Number, stageY:Number, timestamp:int)
		{
			this.id = id;
			this.stageX = stageX;
			this.stageY = stageY;
			this.timestamp = timestamp;
		}
		
		public function update(stageX:Number, stageY:Number, timestamp:int):void
		{
			this.stageX = stageX;
			this.stageY = stageY;
			this.timestamp = timestamp;
		}
		
		public function isLocationEqual(px:Number, py:Number):Boolean
		{
			return stageX == px && stageY == py;
		}
	}
}