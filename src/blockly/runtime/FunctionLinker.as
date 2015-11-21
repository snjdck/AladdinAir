package blockly.runtime
{
	import array.append;
	
	import blockly.OpCode;
	import blockly.OpFactory;
	
	import dict.hasKey;

	internal class FunctionLinker
	{
		private var compiler:JsonCodeToAssembly;
		
		public function FunctionLinker(compiler:JsonCodeToAssembly)
		{
			this.compiler = compiler;
		}
		
		public function link(codeList:Array, functionDict:Object):void
		{
			if(!hasFunctionInvoke(codeList)){
				return;
			}
			var functionIndexDict:Object = {};
			var functionCode:Array = [];
			collectInvokedFunctions(codeList, functionDict, functionCode, functionIndexDict);
			codeList.push(OpFactory.Jump(functionCode.length + 1));
			var functionCodeOffset:int = codeList.length;
			append(codeList, functionCode);
			calcInvokeAddress(codeList, functionIndexDict, functionCodeOffset);
		}
		
		private function hasFunctionInvoke(codeList:Array):Boolean
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				if(codeList[i][0] == OpCode.INVOKE){
					return true;
				}
			}
			return false;
		}
		
		private function collectInvokedFunctions(codeList:Array, functionDict:Object, resultCode:Array, functionIndexDict:Object):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.INVOKE){
					continue;
				}
				var funcName:String = code[1];
				if(hasKey(functionIndexDict, funcName)){
					continue;
				}
				functionIndexDict[funcName] = resultCode.length;
				var functionCode:Array = compiler.translate(functionDict[funcName]);
				append(resultCode, functionCode);
				collectInvokedFunctions(functionCode, functionDict, resultCode, functionIndexDict);
			}
		}
		
		private function calcInvokeAddress(codeList:Array, functionIndexDict:Object, offset:int):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.INVOKE){
					continue;
				}
				code[1] = functionIndexDict[code[1]] + offset - i;
			}
		}
	}
}