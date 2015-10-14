package blockly.design
{
	import array.pushIfNotHas;
	
	import string.repeat;

	public class ArduinoOutput
	{
		private var includeList:Array;
		private var codeList:Array;
		
		public function ArduinoOutput()
		{
			includeList = [];
			codeList = [];
		}
		
		public function addInclude(path:String, isSysLib:Boolean=false):void
		{
			if(isSysLib){
				path = "#include <" + path + ">";
			}else{
				path = '#include "' + path + '"';
			}
			pushIfNotHas(includeList, path);
		}
		
		public function addVarDefine(varType:String, varName:String):void
		{
			
		}
		
		public function addCode(code:String, indent:int):void
		{
			codeList.push(repeat("\t", indent) + code);
		}
		
		public function toString():String
		{
			var result:String = "";
			result += includeList.join("\n");
			result += "\n";
			result += codeList.join("\n");
			return result;
		}
	}
}