package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * 一个out可以连接到多个in
	 * 一个in只能连接一个out
	 * 每个box
	 * @author dell
	 * 
	 */	
	public class CirclePoint extends Sprite
	{
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
	}
}