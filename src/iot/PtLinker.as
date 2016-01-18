package iot
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class PtLinker extends Sprite
	{
		public function PtLinker(from:CirclePoint, to:CirclePoint)
		{
			var g:Graphics = graphics;
			g.lineStyle(2);
			g.moveTo(from.globalX, from.globalY);
			g.lineTo(to.globalX, to.globalY);
		}
	}
}