package blockly.design
{
	import string.genFuncCall;

	public class ArduinoOutputEx extends ArduinoOutput
	{
		private var cmdDict:ArduinoCmdDict;
		
		public function ArduinoOutputEx(cmdDict:ArduinoCmdDict)
		{
			this.cmdDict = cmdDict;
		}
		
		private function outputExpression(block:BlockBase):String
		{
			return onGenArduinoExpression(block, collectArgs(block));
		}
		
		private function collectArgs(block:BlockBase):Array
		{
			var argList:Array = [];
			for(var i:int=0; i<block.defaultArgBlockList.length; ++i){
				argList.push(outputArg(block, i));
			}
			return argList;
		}
		
		private function outputArg(block:BlockBase, index:int):String
		{
			var argBlock:BlockBase = block.argBlockList[index];
			if(argBlock != null){
				return outputExpression(argBlock);
			}
			return block.defaultArgBlockList[index].text;
		}
		
		final public function outputCodeAll(block:BlockBase, indent:int):void
		{
			while(block != null){
				outputCodeSelf(block, indent);
				block = block.nextBlock;
			}
		}
		
		final public function outputCodeSelf(block:BlockBase, indent:int):void
		{
			switch(block.type){
				case BlockBase.BLOCK_TYPE_BREAK:
					addCode("break;", indent);
					break;
				case BlockBase.BLOCK_TYPE_CONTINUE:
					addCode("continue;", indent);
					break;
				case BlockBase.BLOCK_TYPE_STATEMENT:
					onGenArduinoStatement(block, collectArgs(block), indent);
					break;
				case BlockBase.BLOCK_TYPE_FOR:
					addCode("while(" + outputArg(block, 0) + "){", indent);
					if(block.subBlock1 != null){
						outputCodeAll(block.subBlock1, indent + 1);
					}
					addCode("}", indent);
					break;
				case BlockBase.BLOCK_TYPE_IF:
					addCode("if(" + outputArg(block, 0) + "){", indent);
					if(block.subBlock1 != null){
						outputCodeAll(block.subBlock1, indent + 1);
					}
					if(block.subBlock2 != null){
						addCode("}else{", indent);
						outputCodeAll(block.subBlock2, indent + 1);
					}
					addCode("}", indent);
					break;
			}
		}
		
		private function onGenArduinoExpression(block:BlockBase, argList:Array):String
		{
			if(cmdDict.hasCmd(block.cmd)){
				return cmdDict.translate(this, block.cmd, argList);
			}
			return genFuncCall(block.cmd, argList);
		}
		
		private function onGenArduinoStatement(block:BlockBase, argList:Array, indent:int):void
		{
			if(cmdDict.hasCmd(block.cmd)){
				cmdDict.translate(this, block.cmd, argList, indent);
			}
			addCode(genFuncCall(block.cmd, argList) + ";", indent);
		}
	}
}