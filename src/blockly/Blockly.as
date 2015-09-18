package blockly
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.utils.HexUtil;
	
	import blockly.design.InsertPtInfo;
	import blockly.design.MyBlock;
	import blockly.design.blocks.ExpressionBlock;
	import blockly.design.blocks.StatementBlock;
	
	[SWF(frameRate="60")]
	public class Blockly extends Sprite
	{
		
		public function Blockly()
		{
//			var a:BlockShape = new BlockShape();
//			addChild(a);
//			a.block.inputCount = 3;
//			a.block.innerInput = new Block();
//			a.block.innerInput.isStatement = true;
//			a.block.inn
//			a.draw(200, 200);
			var exp:MyBlock = create("show face %d.port x:%1 y:%n characters:%s", StatementBlock);
			var exp:MyBlock = create("show face %d.port x:%2 y:%n characters:%s", StatementBlock);
			var exp:MyBlock = create("show face %d.port x:%3 y:%n characters:%s", StatementBlock);
			
			create("set motor%d.motorPort speed %d.motorvalue", ExpressionBlock);
			create("%d + %d", ExpressionBlock);
		}
		
		private function create(spec:String, type:Class):MyBlock
		{
			var exp:MyBlock = new type();
			exp.addEventListener("drag_begin", __onDragBegin);
			exp.addEventListener("drag_end", __onDragEnd);
			exp.setSpec(spec);
			addChild(exp);
			blockList.push(exp);
			exp.y = 50 * blockList.length;
			return exp;
		}
		
		private var blockList:Array = [];
		private var dragTarget:MyBlock;
		private var dropTarget:InsertPtInfo;
		
		protected function __onDragBegin(event:Event):void
		{
			dragTarget = event.currentTarget as MyBlock;
			var pt:Point = dragTarget.localToGlobal(new Point());
			if(dragTarget.parent != this){
				dragTarget.parent["removeArg"](dragTarget);
				addChild(dragTarget);
				dragTarget.x = pt.x;
				dragTarget.y = pt.y;
			}else if(!dragTarget.isExpression && dragTarget.prevBlock){
				dragTarget.prevBlock.nextBlock = null;
				dragTarget.prevBlock = null;
			}
//			setChildIndex(dragTarget, numChildren-1);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
		}
		
		protected function __onDragEnd(event:Event):void
		{
			dragTarget.filters = null;
			if(dropTarget != null){
//				if(dragTarget.isExpression){
//					(dropTarget.block as MyBlock).acceptDrop(dragTarget);
//				}else{
//				}
				dropTarget.insert(dragTarget);
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
			
			dragTarget = null;
			dropTarget = null;
		}
		
		private function __onMouseMove(evt:MouseEvent):void
		{
			dropTarget = null;
			for each(var block:MyBlock in blockList){
				if(block.parent != this){
					continue;
				}
				if(block == dragTarget){
					continue;
				}
				if(dragTarget.isExpression){
					dropTarget = block.tryAccept(dragTarget)
					if(dropTarget != null){
						break;
					}
				}else if(block.isTopBlock()){
					dropTarget = block.tryLink(dragTarget);
					if(dropTarget != null){
						break;
					}
				}
			}
			if(dropTarget != null){
				dragTarget.filters = [glow];
			}else{
				dragTarget.filters = null;
			}
				
		}
		
		private var glow:GlowFilter = new GlowFilter();
	}
}