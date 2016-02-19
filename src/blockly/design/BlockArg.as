package blockly.design
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	public class BlockArg extends Sprite implements IBlockArg
	{
		public var block:BlockBase;
		public var argIndex:int;
		private var tf:TextField;
		private var type:Array;
		
		public function BlockArg(block:BlockBase, type:Array, argIndex:int)
		{
			this.block = block;
			this.type = type;
			this.argIndex = argIndex;
			tf = new TextField();
			tf.tabEnabled = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.doubleClickEnabled = true;
			tf.addEventListener(MouseEvent.DOUBLE_CLICK, __onMouseDown);
			tf.addEventListener(Event.CHANGE, __onTextChange);
			tf.addEventListener(FocusEvent.FOCUS_IN, __onFocusIn);
			tf.addEventListener(FocusEvent.FOCUS_OUT, __onFocusOut);
			addEventListener(MouseEvent.CLICK, __onClick);
			addChild(tf);
		}
		
		private function __onTextChange(evt:Event):void
		{
			onRedraw();
			var testBlock:BlockBase = block;
			do{
				testBlock.layoutChildren();
				testBlock.drawBg();
				testBlock = testBlock.parentBlock;
			}while(testBlock != null);
		}
		
		private function __onClick(evt:MouseEvent):void
		{
			if(evt.target != this){
				return;
			}
//			BlockContextMenuMgr.Instance.show(this, type[2]);
		}
		
		private function __onMouseDown(evt:MouseEvent):void
		{
			focusOn();
		}
		
		private function __onFocusIn(evt:FocusEvent):void
		{
			tf.type = TextFieldType.INPUT;
			tf.setSelection(0, tf.text.length);
		}
		
		private function __onFocusOut(evt:FocusEvent):void
		{
			tf.type = TextFieldType.DYNAMIC;
		}
		
		public function get text():String
		{
			return tf.text;
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
				if(w < tf.textHeight){
					w = tf.textHeight;
				}
				g.drawRoundRect(0, 2, w, tf.textHeight, tf.textHeight, tf.textHeight);
			}
			
			g.endFill();
			
			if(hasArrow()){
				g.beginFill(0);
				drawTri(g, tf.textWidth+4, 6);
				g.endFill();
			}
		}
		
		private function drawTri(g:Graphics, px:Number, py:Number):void
		{
			g.moveTo(px, py);
			g.lineTo(px+8, py);
			g.lineTo(px+4, py+4);
			g.lineTo(px, py);
		}
		
		public function focusOn():void
		{
			stage.focus = tf;
		}
	}
}