package blockly
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import blockly.design.ArduinoOutputEx;
	import blockly.design.BlockBase;
	import blockly.design.BlockJsonOutput;
	import blockly.design.FocusMgr;
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
		private var blockDict:Object = {};
		
		[Embed(source="blockDef.xml", mimeType="application/octet-stream")]
		static public const BIN:Class;
		
		public function Blockly()
		{
			var blockDef:XML = XML(new BIN().toString());
			
			for each(var group:XML in blockDef.children()){
				var dock:Sprite = new Sprite();
				blockDict[group.@name] = dock;
				blockDock.addChild(dock);
				for each(var item:XML in group.children()){
					var blockFlag:int = item.name().localName == "statement" ?　BlockBase.BLOCK_TYPE_STATEMENT　:　BlockBase.BLOCK_TYPE_EXPRESSION;
					create(item.@id, item.@spec, blockFlag, dock);
				}
			}
			
			dock = new Sprite();
			blockDict["Control"] = dock;
			blockDock.addChild(dock);
			create("+", "%d + %d", BlockBase.BLOCK_TYPE_EXPRESSION, dock);
			create(null, "forever %0", BlockBase.BLOCK_TYPE_FOR, dock);
			create(null, "if %d    ", BlockBase.BLOCK_TYPE_IF, dock);
			create(null, "else if %d  ", BlockBase.BLOCK_TYPE_ELSE_IF, dock);
			create(null, "else        ", BlockBase.BLOCK_TYPE_ELSE, dock);
			create(null, "break", BlockBase.BLOCK_TYPE_BREAK, dock);
			create(null, "continue", BlockBase.BLOCK_TYPE_CONTINUE, dock);
			create(null, "arduino", BlockBase.BLOCK_TYPE_ARDUINO, dock);
			
			addChild(blockDock);
			addChild(indicator);
			
			new FocusMgr(stage);
			addChild(new MenuPart(blockDict)).x = 300;
		}
		
		private function create(cmd:String, spec:String, type:int, viewParent:Sprite):void
		{
			var exp:MyBlock = new MyBlock();
			exp.type = type;
			exp.addEventListener("drag_begin", __onDragBegin);
			exp.addEventListener("drag_end", __onDragEnd);
			exp.cmd = cmd;
			exp.setSpec(spec);
			exp.y = 10 + 50 * viewParent.numChildren;
			blockList.push(exp);
			viewParent.addChild(exp);
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
			dragTarget.relayout();
			dragTarget.layoutAfterInsertBelow();
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