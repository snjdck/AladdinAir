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
			return JSON.stringify(code);
		}
	}
}