package blockly
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import blockly.design.InsertPtInfo;
	import blockly.design.MyBlock;
	import blockly.design.blocks.ExpressionBlock;
	import blockly.design.blocks.StatementBlock;
	
	[SWF(frameRate="60")]
	public class Blockly extends Sprite
	{
		
		public function Blockly()
		{
			create("showFace", "show face %d.port x:%1 y:%n characters:%s", StatementBlock);
			create("showFace", "show face %d.port x:%2 y:%n characters:%s", StatementBlock);
			create("showFace", "show face %d.port x:%3 y:%n characters:%s", StatementBlock);
			
			create("setMotor", "set motor%d.motorPort speed %d.motorvalue", ExpressionBlock);
			create("add", "%d + %d", ExpressionBlock);
		}
		
		private function create(cmd:String, spec:String, type:Class):MyBlock
		{
			var exp:MyBlock = new type();
			exp.addEventListener("drag_begin", __onDragBegin);
			exp.addEventListener("drag_end", __onDragEnd);
			exp.cmd = cmd;
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
			dragTarget.dragBegin();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
		}
		
		private function __onDragEnd(event:Event):void
		{
			if(dropTarget != null){
				dropTarget.insert(dragTarget);
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
			dragTarget = null;
			dropTarget = null;
			trace(findRunableBlocks());
		}
		
		private function __onMouseMove(evt:MouseEvent):void
		{
			dropTarget = null;
			for each(var block:MyBlock in blockList){
				if(block == dragTarget){
					continue;
				}
				if(dragTarget.isExpression){
					if(block.parentBlock){
						continue;
					}
					dropTarget = block.tryAccept(dragTarget)
				}else if(block.isTopBlock()){
					dropTarget = block.tryLink(dragTarget);
				}
				if(dropTarget != null){
					break;
				}
			}
		}
		
		private function findRunableBlocks():Array
		{
			var result:Array = [];
			for each(var block:MyBlock in blockList){
				if(block.isTopBlock()){
					result.push(block);
					trace(block.getTotalCode());
				}
			}
			return result;
		}
	}
}