package blockly.design
{
	public class PreCompiler
	{
		public function PreCompiler()
		{
		}
		
		public function precompile(codeList:Array):void
		{
			if(null == codeList){
				return;
			}
			var index:int = 0;
			while(index < codeList.length){
				var code:Array = codeList[index];
				switch(code["type"]){
					case "if":
						precompile(code["caseTrue"]);
						precompile(code["caseFalse"]);
						break;
					case "while":
						precompile(code["loop"]);
						break;
					default:
						if(replaceCode(codeList, index)){
							continue;
						}
				}
				++index;
			}
		}
		
		private function replaceCode(codeList:Array, index:int):Boolean
		{
			var code:Array = codeList[index];
			switch(code["type"]){
				case "until":
					code["type"] = "while";
					code["condition"] = {"type":"function", "method":"not", "argList":[code["condition"]]};
					break;
				case "unless":
					code["type"] = "if";
					code["condition"] = {"type":"function", "method":"not", "argList":[code["condition"]]};
					break;
				case "loopTimes":
					code["type"] = "for";
					break;
				default:
					return false;
			}
			return true;
		}
	}
}