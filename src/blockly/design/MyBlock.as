package blockly.design
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import blockly.Spec;

	public class MyBlock extends BlockBase implements IBlockArg
	{
		static public const gapX:int = 2;
		
		public var typeId:int;
		
		private var filterList:Array;
		private var spec:Spec;
		
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
			layoutAfterInsertBelow();
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
		
		public function setSpec(info:String):void
		{
			this.spec = new Spec(info);
			onSetSpec(spec.nodeList);
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
					var ui:BlockArg = new BlockArg(this, info);
					addChild(ui);
					ui.text = info[1];
					defaultArgBlockList.push(ui);
				}
			}
			layoutChildren();
			drawBg();
		}
		
		public function tryAccept(other:MyBlock):InsertPtInfo
		{
			for(var i:int=0; i<defaultArgBlockList.length; i++){
				var argBlock:MyBlock = argBlockList[i];
				if(argBlock != null){
					var result:InsertPtInfo = argBlock.tryAccept(other)
					if(result != null){
						return result;
					}
				}
				if(other.hitTestObject(getArgBlockAt(i))){
					return new InsertPtInfo(this, BlockBase.INSERT_PT_CHILD, i);
				}
			}
			return null;
		}
		
		private function getArgBlockAt(index:int):DisplayObject
		{
			if(argBlockList[index]){
				return argBlockList[index];
			}
			return defaultArgBlockList[index];
		}
		
		static private const insertPtsFilter:InsertPtsFilter = new InsertPtsFilter();
		
		public function tryLink(dragTarget:BlockBase):InsertPtInfo
		{
			if(!isElseBlock()){
				if(dragTarget.isNearTo(x, y - dragTarget.getTotalBlockHeight())){
					return new InsertPtInfo(this, INSERT_PT_ABOVE);
				}
				if(dragTarget.isControlBlock()){
					if(null == dragTarget.subBlock1 && dragTarget.isNearTo(x, y - dragTarget.getPositionSub1())){
						return new InsertPtInfo(this, INSERT_PT_WRAP, 0);
					}
					if(dragTarget.hasSubBlock2() && null == dragTarget.subBlock2 && dragTarget.isNearTo(x, y - dragTarget.getPositionSub2())){
						return new InsertPtInfo(this, INSERT_PT_WRAP, 1);
					}
				}
			}
			var ptList:Array = insertPtsFilter.filter(calcInsertPt(), dragTarget.type);
			for each(var ptInfo:InsertPtInfo in ptList){
				var target:BlockBase = ptInfo.block;
				switch(ptInfo.type){
					case INSERT_PT_BELOW:
						if(dragTarget.isNearTo(target.x, target.y + target.getBlockHeight())){
							return ptInfo;
						}
						break;
					case INSERT_PT_SUB1:
						if(dragTarget.isNearTo(target.x, target.y + target.getPositionSub1())){
							return ptInfo;
						}
						break;
					case INSERT_PT_SUB2:
						if(dragTarget.isNearTo(target.x, target.y + target.getPositionSub2())){
							return ptInfo;
						}
						break;
				}
			}
			return null;
		}
	}
}