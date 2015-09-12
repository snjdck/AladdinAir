package blockly
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class BlockShape extends Sprite
	{
		public var block:Block;
		
		public function BlockShape()
		{
			block = new Block();
			addEventListener(MouseEvent.MOUSE_DOWN, __onMouseDown);
		}
		
		private function __onMouseDown(evt:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			startDrag();
		}
		
		private function __onMouseUp(evt:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
		}
		
		public function draw(w:int, h:int):void
		{
			block.draw(graphics, 0, 0, w, h);
		}
	}
}