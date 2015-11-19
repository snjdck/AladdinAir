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
			if(!hasFunctionInvoke(codeList)){
				return;
			}
			
			var codeSize:int = codeList.length;
			codeList.push(OpFactory.Jump(0));
			
			var compiledFunctionDict:Object = {};
			collectInvokedFunctions(codeList, functionDict, compiledFunctionDict);
			var functionIndexDict:Object = {};
			
			for(var key:String in compiledFunctionDict){
				functionIndexDict[key] = codeList.length;
				append(codeList, functionIndexDict[key]);
			}
			
			for(var i:int=0, n:int=codeList.length; i<n; ++i){
				var code:Array = codeList[i];
				if(code[0] != OpCode.INVOKE){
					continue;
				}
				var funcName:String = code[1];
				codeList[i] = OpFactory.Invoke(functionIndexDict[funcName] - i);
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
				compiledFunctionDict[funcName] = functionCode;
				collectInvokedFunctions(functionCode, functionDict, compiledFunctionDict);
			}
		}
	}
}