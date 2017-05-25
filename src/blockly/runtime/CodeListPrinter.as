package blockly.runtime
{
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
			if(code.length <= 1){
				return code[0];
			}
			return code[0] + "," + JSON.stringify(code.slice(1)).slice(1, -1);
		}
	}
}