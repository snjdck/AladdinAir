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
		
		private function outputExpression(block:Object):String
		{
			if(block is String){
				return block as String;
			}
			return onGenArduinoExpression(block);
		}
		
		private function collectArgs(block:Object):Array
		{
			var argList:Array = block["argList"];
			var n:int = argList != null ? argList.length : 0;
			var result:Array = [];
			for(var i:int=0; i<n; ++i){
				result[i] = outputExpression(argList[i]);
			}
			return result;
		}
		
		final public function outputCodeAll(blockList:Array, indent:int):void
		{
			for each(var block:Object in blockList){
				outputCodeSelf(block, indent);
			}
		}
		
		final public function outputCodeSelf(block:Object, indent:int):void
		{
			switch(block["type"]){
				case "break":
					addCode("break;", indent);
					break;
				case "continue":
					addCode("continue;", indent);
					break;
				case "function":
					onGenArduinoStatement(block, indent);
					break;
				case "if":
					addCode("if(" + outputExpression(block["condition"]) + "){", indent);
					outputCodeAll(block["caseTrue"], indent + 1);
					if(block["caseFalse"] != null){
						addCode("}else{", indent);
						outputCodeAll(block["caseFalse"], indent + 1);
					}
					addCode("}", indent);
					break;
				case "while":
					addCode("while(" + outputExpression(block["condition"]) + "){", indent);
					outputCodeAll(block["loop"], indent + 1);
					addCode("}", indent);
					break;
			}
		}
		
		private function onGenArduinoExpression(block:Object):String
		{
			var method:String = block["method"];
			var argList:Array = collectArgs(block);
			if(cmdDict.hasCmd(method)){
				return cmdDict.translate(this, method, argList);
			}
			return genFuncCall(method, argList);
		}
		
		private function onGenArduinoStatement(block:Object, indent:int):void
		{
			var method:String = block["method"];
			if(cmdDict.hasCmd(method)){
				cmdDict.translate(this, method, collectArgs(block), indent);
			}else{
				addCode(onGenArduinoExpression(block) + ";", indent);
			}
		}
	}
}