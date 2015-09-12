package blockly.design
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	public class BlockArg extends Sprite implements IBlockArg
	{
		private var tf:TextField;
		private var type:Array;
		
		public function BlockArg(type:Array)
		{
			this.type = type;
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.doubleClickEnabled = true;
			tf.addEventListener(MouseEvent.DOUBLE_CLICK, __onMouseDown);
			addEventListener(MouseEvent.CLICK, __onClick);
			addChild(tf);
		}
		
		private function __onClick(evt:MouseEvent):void
		{
			if(evt.target != this){
				return;
			}
			trace("arrao click");
		}
		
		private function __onMouseDown(evt:MouseEvent):void
		{
			tf.type = TextFieldType.INPUT;
			tf.setSelection(0, 0);
			tf.addEventListener(FocusEvent.FOCUS_OUT, __onFocusOut);
		}
		
		private function __onFocusOut(evt:FocusEvent):void
		{
			tf.type = TextFieldType.DYNAMIC;
		}
		
		public function set text(value:String):void
		{
			tf.text = value;
			onRedraw();
		}
		
		public function isString():Boolean
		{
			return type[1] == "s";
		}
		
		public function hasArrow():Boolean
		{
			return type[2] != null;
		}
		
		private function onRedraw():void
		{
			var g:Graphics = graphics;
			
			var w:int = hasArrow() ? tf.width + 10 : tf.width;
			
			g.clear();
			g.beginFill(0xFFFFFF);
			
			if(isString()){
				g.drawRect(0, 2, w, tf.textHeight);
			}else{
				g.drawRoundRect(0, 2, w, tf.textHeight, tf.textHeight, tf.textHeight);
			}
			
			g.endFill();
			
			if(hasArrow()){
				g.beginFill(0);
				drarTri(g, tf.textWidth+4, 6);
				g.endFill();
			}
		}
		
		private function drarTri(g:Graphics, px:Number, py:Number):void
		{
			g.moveTo(px, py);
			g.lineTo(px+8, py);
			g.lineTo(px+4, py+4);
			g.lineTo(px, py);
		}
	}
}