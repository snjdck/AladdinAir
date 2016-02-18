package blockly
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import blockly.design.ArduinoOutputEx;
	import blockly.design.BlockArg;
	import blockly.design.BlockBase;
	import blockly.design.BlockJsonOutput;
	import blockly.design.InsertPtIndicator;
	import blockly.design.InsertPtInfo;
	import blockly.design.MyBlock;
	import blockly.design.OrionCmdDict;
	import blockly.runtime.Interpreter;
	import blockly.util.ArduinoFunctionProvider;
	
	
	[SWF(frameRate="60", width="1000", height="800")]
	public class Blockly extends Sprite
	{
		private var blockDock:Sprite = new Sprite();
		
		public function Blockly()
		{
//			var jsonObj:Array = [];
//			jsonObj.push(SyntaxTreeFactory.NewFunction(["a"], [SyntaxTreeFactory.NewStatement("trace", [SyntaxTreeFactory.GetParam("a")])]));
//			jsonObj.push(SyntaxTreeFactory.RunFunction([SyntaxTreeFactory.NewString("shaokai")], 0));
//			var assembly:Array = interpreter.compile(jsonObj);
//			trace(assembly.join("\n"));
//			trace("interpreter");
//			interpreter.execute(jsonObj);
//			return;
			create("showFace", "show face %d.port x:%1 y:%n characters:%s", BlockBase.BLOCK_TYPE_STATEMENT);
//			create("showFace", "show face %d.port x:%2 y:%n characters:%s", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_BLUE);
//			create("showFace", "show face %d.port x:%3 y:%n characters:%s", BlockBase.BLOCK_TYPE_STATEMENT, BlockFlag.PORT_BLUE);
			
			create("runMotor", "set motor%d.motorPort speed %d.motorvalue", BlockBase.BLOCK_TYPE_STATEMENT);
			create("runServo", "set servo %d.servoPort %d.slot angle %d.servovalue", BlockBase.BLOCK_TYPE_STATEMENT);
			create("getUltrasonic", "ultrasonic sensor %d.normalPort distance", BlockBase.BLOCK_TYPE_EXPRESSION);
			
			create("+", "%d + %d", BlockBase.BLOCK_TYPE_EXPRESSION);
			create(null, "forever %0", BlockBase.BLOCK_TYPE_FOR);
			create(null, "if %d    ", BlockBase.BLOCK_TYPE_IF);
			create(null, "else if %d  ", BlockBase.BLOCK_TYPE_ELSE_IF);
			create(null, "else        ", BlockBase.BLOCK_TYPE_ELSE);
			create(null, "break", BlockBase.BLOCK_TYPE_BREAK);
			create(null, "continue", BlockBase.BLOCK_TYPE_CONTINUE);
			create(null, "arduino", BlockBase.BLOCK_TYPE_ARDUINO);
			
			addChild(blockDock);
			addChild(indicator);
			
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, __onFocusChange);
		}
		//*
		private function __onFocusChange(evt:FocusEvent):void
		{
			var blockArg:BlockArg = evt.target.parent as BlockArg;
			if(blockArg == null){
				return;
			}
			blockArg.setNextFocus();
		}
		//*/
		private function create(cmd:String, spec:String, type:int, flag:uint=0):MyBlock
		{
			var exp:MyBlock = new MyBlock();
			exp.flag = flag;
			exp.type = type;
			exp.addEventListener("drag_begin", __onDragBegin);
			exp.addEventListener("drag_end", __onDragEnd);
			exp.cmd = cmd;
			exp.setSpec(spec);
			blockDock.addChild(exp);
			exp.y = 10 + 50 * blockList.length;
			blockList.push(exp);
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
			indicator.clear();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, __onMouseMove);
			dragTarget = null;
			dropTarget = null;
			trace(findRunableBlocks());
		}
		
		private function __onMouseMove(evt:MouseEvent):void
		{
			dropTarget = findDropTarget();
			indicator.indicate(dragTarget, dropTarget);
		}
		
		private function findDropTarget():InsertPtInfo
		{
			var result:InsertPtInfo;
			for each(var block:MyBlock in blockList){
				if(block == dragTarget){
					continue;
				}
				if(dragTarget.isExpression()){
					if(block.isExpression() && block.parentBlock){
						continue;
					}
					result = block.tryAccept(dragTarget);
				}else if(block.isTopBlock()){
					result = block.tryLink(dragTarget);
				}
				if(result != null){
					break;
				}
			}
			return result;
		}
		
		private var indicator:InsertPtIndicator = new InsertPtIndicator();
		private var interpreter:Interpreter = new Interpreter(new ArduinoFunctionProvider());
		private function findRunableBlocks():Array
		{
			trace("============================begin");
			interpreter.stopAllThreads();
			var result:Array = [];
			for each(var block:MyBlock in blockList){
				if(block.isTopBlock()){
					result.push(block);
//					trace(block.getTotalCode().join("\n"));
					var cmdDict:OrionCmdDict = new OrionCmdDict();
					var temp:ArduinoOutputEx = new ArduinoOutputEx(cmdDict);
					
					var jsonObj:Array = new BlockJsonOutput().outputCodeAll(block);
					temp.outputCodeAll(jsonObj, 0);
					trace(JSON.stringify(jsonObj));
					trace("cpp");
					trace(temp);
					trace("assembly");
					var assembly:Array = interpreter.compile(jsonObj);
					trace(assembly.join("\n"));
					trace("interpreter");
					interpreter.execute(jsonObj);
					
					trace("--------------------------------");
				}
			}
			trace("============================end");
			return result;
		}
	}
}