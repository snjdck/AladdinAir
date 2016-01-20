package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * 一个out可以连接到多个in
	 * 一个in只能连接一个out
	 * 每个box有多个in,多个out
	 * intel hope
	 * 自己的输入和输出可以连接
	 */	
	public class CirclePoint extends Sprite
	{
		public const linkedInPtList:Vector.<CirclePoint> = new Vector.<CirclePoint>();
		public var isIn:Boolean;
		
		public function CirclePoint(isIn:Boolean)
		{
			this.isIn = isIn;
			var g:Graphics = graphics;
			
			g.lineStyle(2);
			g.beginFill(0,0);
			g.drawCircle(0,0,8);
			g.endFill();
		}
		
		public function get box():Box
		{
			return parent as Box;
		}
		
		public function get globalX():Number
		{
			return parent.x + x;
		}
		
		public function get globalY():Number
		{
			return parent.y + y;
		}
		
		public function hasPt(value:CirclePoint):Boolean
		{
			return linkedInPtList.indexOf(value) >= 0;
		}
		
		public function addPt(value:CirclePoint):void
		{
			linkedInPtList.push(value);
		}
		
		public function removePt(value:CirclePoint):void
		{
			var index:int = linkedInPtList.indexOf(value);
			if(index >= 0){
				linkedInPtList.splice(index, 1);
			}
		}
	}
}