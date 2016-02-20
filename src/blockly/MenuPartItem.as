package blockly
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public class MenuPartItem extends Sprite
	{
		static private const minW:int = 7;
		static private const maxW:int = 160;
		static private const HEIGHT:int = 20;
		
		static private const overColor:uint = 0xFBA939;
		static private const outColor:uint = 0x8F9193;
		
		private var tf:TextField;
		private var color:uint;
		private var isSelected:Boolean;
		
		private var view:Sprite;
		
		public function MenuPartItem(title:String, color:uint, view:Sprite)
		{
			this.view = view;
			mouseChildren = false;
			tf = new TextField();
			tf.x = minW + 2;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = title;
			addChild(tf);
			
			this.color = color;
			
			addEventListener(MouseEvent.ROLL_OVER, __onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, __onRollOut);
		}
		
		private function __onRollOver(evt:MouseEvent):void
		{
			if(isSelected){
				return;
			}
			tf.textColor = overColor;
		}
		
		private function __onRollOut(evt:MouseEvent):void
		{
			if(isSelected){
				return;
			}
			tf.textColor = outColor;
		}
		
		public function setSelected(value:Boolean):void
		{
			isSelected = value;
			var g:Graphics = graphics;
			g.clear();
			
			if(value){
				tf.textColor = 0xFFFFFF;
				g.beginFill(color);
				g.drawRect(0, 0, maxW, HEIGHT);
				g.endFill();
			}else{
				tf.textColor = outColor;
				g.beginFill(color);
				g.drawRect(0, 0, minW, HEIGHT);
				g.endFill();
				g.beginFill(0, 0);
				g.drawRect(minW, 0, maxW-minW, HEIGHT);
				g.endFill();
			}
			
			if(view != null)
			view.visible = value;
		}
	}
}