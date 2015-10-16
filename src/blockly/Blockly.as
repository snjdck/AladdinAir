package blockly
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import blockly.blocks.RunMotorBlock;
	import blockly.design.ArduinoOutput;
	import blockly.design.BlockBase;
	import blockly.design.InsertPtInfo;
	import blockly.design.MyBlock;
	
	[SWF(frameRate="60", width="1000", height="600")]
	public class Blockly extends Sprite
	{
		public function Blockly()
		{
			create("showFace", "show face %d.port x:%1 y:%n characters:%s", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_BLUE);
			create("showFace", "show face %d.port x:%2 y:%n characters:%s", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_BLUE);
			create("showFace", "show face %d.port x:%3 y:%n characters:%s", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_BLUE);
			
			create("runMotor", "set motor%d.motorPort speed %d.motorvalue", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_RED, RunMotorBlock);
			create("runServo", "set servo %d.servoPort %d.slot angle %d.servovalue", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_RED);
			create("getUltrasonic", "ultrasonic sensor %d.normalPort distance", BlockBase.BLOCK_TYPE_EXPRESSION, BlockFlag.PORT_YELLOW);
			
			create("add", "%d + %d", BlockBase.BLOCK_TYPE_EXPRESSION);
			create(null, "forever %d", BlockBase.BLOCK_TYPE_FOR);
			create(null, "if %d", BlockBase.BLOCK_TYPE_IF);
			create(null, "break", BlockBase.BLOCK_TYPE_BREAK);
			create(null, "continue", BlockBase.BLOCK_TYPE_CONTINUE);
		}
		
		private function create(cmd:String, spec:String, type:int, flag:uint=0, blockCls:Class=null):MyBlock
		{
			var exp:MyBlock = blockCls ? new blockCls() : new MyBlock();
			exp.flag = flag;
			exp.type = type;
			exp.addEventListener("drag_begin", __onDragBegin);
			exp.addEventListener("drag_end", __onDragEnd);
			exp.cmd = cmd;
			exp.setSpec(spec);
			addChild(exp);
			blockList.push(exp);
			exp.y = 60 * blockList.length;
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
				if(dragTarget.isExpression()){
					if(block.isExpression() && block.parentBlock){
						continue;
					}
					dropTarget = block.tryAccept(dragTarget);
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
			trace("============================begin");
			var result:Array = [];
			for each(var block:MyBlock in blockList){
				if(block.isTopBlock()){
					result.push(block);
//					trace(block.getTotalCode().join("\n"));
					var temp:ArduinoOutput = new ArduinoOutput();
					block.outputCodeAll(temp, 0);
					trace(temp);
				}
			}
			trace("============================end");
			return result;
		}
	}
}