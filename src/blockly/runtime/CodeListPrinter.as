package blockly.runtime
{
	import blockly.OpCode;

	internal class CodeListPrinter
	{
		public function CodeListPrinter(){}
		
		public function castCodeListToString(codeList:Array):String
		{
			var result:Array = [];
			for each(var code:Array in codeList)
				result.push(castCodeToString(code));
			return result.join("\n");
		}
		
		private function castCodeToString(code:Array):String
		{
			var op:String = code[0];
			if(op == OpCode.PUSH){
				var value:* = code[1];
				if(value is String)
					value = '"' + value + '"';
				return op + "," + value;
			}
			return code.join(",");
		}
	}
}