package blockly.runtime
{
	import array.append;
	
	import blockly.OpCode;
	import blockly.OpFactory;

	internal class FunctionLinker
	{
		private var compiler:JsonCodeToAssembly;
		
		public function FunctionLinker(compiler:JsonCodeToAssembly)
		{
			this.compiler = compiler;
		}
		
		public function link(codeList:Array, functionDict:Object):void
		{
//			trace(JSON.stringify(functionDict));
//			return;
			if(!hasFunctionInvoke(codeList)){
				return;
			}
			
			var codeSize:int = codeList.length;
			
			var compiledFunctionDict:Object = {};
			collectInvokedFunctions(codeList, functionDict, compiledFunctionDict);
			var functionIndexDict:Object = {};
			var functionCode:Array = [];
			for(var key:String in compiledFunctionDict){
				functionIndexDict[key] = functionCode.length;
				append(functionCode, compiledFunctionDict[key]);
			}
			codeList.push(OpFactory.Jump(functionCode.length + 1));
			append(codeList, functionCode);
			
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.INVOKE){
					continue;
				}
				var funcName:String = code[1];
				code[1] = functionIndexDict[funcName] + codeSize + 1 - i;
			}
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
		
		private function collectInvokedFunctions(codeList:Array, functionDict:Object, compiledFunctionDict:Object):void
		{
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.INVOKE){
					continue;
				}
				var funcName:String = code[1];
				var functionCode:Array = compiledFunctionDict[funcName];
				if(functionCode != null){
					continue;
				}
				functionCode = compiler.translate(functionDict[funcName]);
				functionCode.push([OpCode.RETURN]);
				compiledFunctionDict[funcName] = functionCode;
				collectInvokedFunctions(functionCode, functionDict, compiledFunctionDict);
			}
		}
	}
}