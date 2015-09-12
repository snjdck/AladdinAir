package blockly.design
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class MyBlock extends BlockBase implements IBlockArg
	{
		static public const gapX:int = 2;
		
		public var typeId:int;
		
		/** 语句参数 */
		public const defaultArgBlock:Array = [];
		public const argBlock:Array = [];
		
		/** if,while,for的子句,条件作为argBlock */
		public var subBlock1:MyBlock;
		public var subBlock2:MyBlock;
		
		public function MyBlock()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, __onMouseDown);
		}

		private function getArgBlockAt(index:int):IBlockArg
		{
			if(argBlock[index] != null){
				return argBlock[index];
			}
			return defaultArgBlock[index];
		}
		
		private function __onMouseDown(evt:MouseEvent):void
		{
			if(evt.target != this){
				return;
			}
			stage.addEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			
			startDrag();
			dispatchEvent(new Event("drag_begin"));
			addEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
		}
		
		private function __onMouseMove(evt:MouseEvent):void
		{
			relayout();
		}
		
		private function __onMouseUp(evt:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, __onMouseUp);
			dispatchEvent(new Event("drag_end"));
			removeEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
		}
		
		public function execute():*
		{
		}
		
		protected function drawBg(w:int, h:int):void
		{
			
		}
		
		public function setSpec(spec:String):void
		{
			var regExp:RegExp = /%(\w)(?:\.(\w+)|)/g;
			var nodeList:Array = [];
			
			var offset:int = 0;
			for(;;){
				var list:Array = regExp.exec(spec);
				if(null == list){
					break;
				}
				nodeList.push(spec.slice(offset, list.index));
				nodeList.push(list);
				offset = list[0].length + list.index;
			}
			if(offset < spec.length){
				nodeList.push(spec.slice(offset, -1));
			}
			trace(JSON.stringify(nodeList));
			onSetSpec(nodeList);
		}
		
		private function onSetSpec(nodeList:Array):void
		{
			for each(var node:* in nodeList){
				if(node is String){
					var tf:TextField = new TextField();
					tf.mouseEnabled = false;
					tf.autoSize = TextFieldAutoSize.LEFT;
					addChild(tf);
					tf.text = node;
				}else{
					var info:Array = node;
					var ui:BlockArg = new BlockArg(info);
					addChild(ui);
					ui.text = info[1];
					defaultArgBlock.push(ui);
				}
			}
			layout();
		}
		
		private var dropArg:DisplayObject;
		
		public function tryAccept(other:MyBlock):Boolean
		{
			dropArg = null;
			var result:Boolean = false;
			for(var i:int=0; i<defaultArgBlock.length; i++){
				var arg:DisplayObject = getArgBlockAt(i) as DisplayObject;
				if(arg.hitTestObject(other) && !result){
					arg.filters = [new GlowFilter()];
					result = true;
					dropArg = arg;
					//					break;
				}else{
					arg.filters = null;
				}
			}
			return result;
		}
		
		public function layout():void
		{
			var offsetX:int = gapX;
			for(var i:int=0; i<numChildren; i++){
				var obj:DisplayObject = getChildAt(i);
				obj.x = offsetX;
				offsetX += obj.width;
			}
			graphics.clear();
			drawBg(width, 20);
		}
		
		public function removeArg(other:MyBlock):void
		{
			var index:int = argBlock.indexOf(other);
			argBlock[index] = null;
			var defaultArg:DisplayObject = defaultArgBlock[index];
			trace(getChildIndex(other));
			addChildAt(defaultArg, getChildIndex(other));
			removeChild(other);
			layout();
		}
		
		public function acceptDrop(other:MyBlock):void
		{
			if(null == dropArg){
				return;
			}
			dropArg.filters = null;
			var index:int = getArgIndex(dropArg);
			trace(getChildIndex(dropArg))
			addChildAt(other, getChildIndex(dropArg));
			if(argBlock[index]){
				parent.addChild(argBlock[index]);
			}else{
				removeChild(dropArg);
			}
			argBlock[index] = other;
			
			other.y = 0;
			layout();
			dropArg = null;
		}
		
		private function getArgIndex(obj:DisplayObject):int
		{
			var index:int;
			index = argBlock.indexOf(obj);
			if(index >= 0){
				return index;
			}
			return defaultArgBlock.indexOf(obj);
		}
		
		public function tryLink(dragTarget:MyBlock):Boolean
		{
			return Math.abs(dragTarget.x-x) <= 10 && Math.abs(dragTarget.y-y-height) <= 6;
		}
		
		public function acceptLink(dragTarget:MyBlock):void
		{
			dragTarget.addBlockToLast(nextBlock);
			nextBlock = dragTarget;
			relayout();
		}
	}
}