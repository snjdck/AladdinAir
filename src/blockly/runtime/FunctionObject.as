package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionObject
	{
		private var context:IScriptContext;
		private var argList:Array;
		private var address:int;
		
		public function FunctionObject(context:IScriptContext, argList:Array, address:int)
		{
			this.context = context;
			this.argList = argList;
			this.address = address;
		}
		
		internal function invoke(thread:Thread, valueList:Array, regCount:int):void
		{
			thread.pushScope(createScope(regCount));
			for(var i:int=argList.length-1; i>=0; --i){
				thread.newVar(argList[i], valueList[i]);
			}
			thread.increaseRegOffset(regCount);
			thread.ip = address;
		}
		
		private function createScope(regCount:int):FunctionScope
		{
			var scope:FunctionScope = new FunctionScope();
			scope.context = context.createChildContext();
			scope.defineAddress = address;
			scope.regCount = regCount;
			return scope;
		}
	}
}