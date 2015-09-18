package blockly.design
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	public class MyBlock extends BlockBase implements IBlockArg
	{
		static public const gapX:int = 2;
		
		public var typeId:int;
		
		/** if,while,for的子句,条件作为argBlock */
		public var subBlock1:MyBlock;
		public var subBlock2:MyBlock;
		
		private var filterList:Array;
		
		public function MyBlock()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, __onMouseDown);
			var f:BevelFilter = new BevelFilter(1);
			f.blurX = f.blurY = 3;
			f.highlightAlpha = 0.3;
			f.shadowAlpha = 0.6;
			filterList = [f];
			filters = filterList;
		}
/*
		private function getArgBlockAt(index:int):IBlockArg
		{
			if(argBlock[index] != null){
				return argBlock[index];
			}
			return defaultArgBlock[index];
		}
	*/	
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
			layoutAfterInsertBelow();
			layoutChildren();
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
					defaultArgBlockList.push(ui);
				}
			}
			layoutChildren();
		}
		
		private var dropArg:DisplayObject;
		
		public function tryAccept(other:MyBlock):InsertPtInfo
		{
			dropArg = null;
			var result:InsertPtInfo;
			for(var i:int=0; i<defaultArgBlockList.length; i++){
				var arg:DisplayObject = getArgBlockAt(i) as DisplayObject;
				if(arg.hitTestObject(other) && !result){
					arg.filters = [new GlowFilter()];
					dropArg = arg;
					result = new InsertPtInfo(this, BlockBase.INSERT_PT_CHILD, i);
					//					break;
				}else{
					arg.filters = null;
				}
			}
			return result;
		}
		/*
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
		*/
		
		private function getArgBlockAt(index:int):DisplayObject
		{
			if(argBlockList[index]){
				return argBlockList[index];
			}
			return defaultArgBlockList[index];
		}
		/*
		private function getArgIndex(obj:DisplayObject):int
		{
			var index:int;
			index = argBlock.indexOf(obj);
			if(index >= 0){
				return index;
			}
			return defaultArgBlock.indexOf(obj);
		}
		*/
		public function tryLink(dragTarget:MyBlock):InsertPtInfo
		{
			var ptList:Array = calcInsertPt();
			for each(var ptInfo:InsertPtInfo in ptList){
				var target:BlockBase = ptInfo.block;
				switch(ptInfo.type){
					case INSERT_PT_ABOVE:
						if( Math.abs(dragTarget.x-target.x) <= 10 && Math.abs(dragTarget.y+dragTarget.getTotalBlockHeight()-target.y) <= 6){
							return ptInfo;
						}
						break;
					case INSERT_PT_BELOW:
						if( Math.abs(dragTarget.x-target.x) <= 10 && Math.abs(dragTarget.y-target.y-target.getBlockHeight()) <= 6){
							return ptInfo;
						}
						break;
				}
			}
			return null;
		}
		/*
		public function acceptLink(dragTarget:MyBlock):void
		{
			dragTarget.addBlockToLast(nextBlock);
			nextBlock = dragTarget;
			relayout();
		}
		*/
	}
}