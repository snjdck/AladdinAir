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
			thread.pushScope(createScope(thread, regCount));
			for(var i:int=argList.length-1; i>=0; --i)
				thread.newVar(argList[i], valueList[i]);
		}
		
		private function createScope(thread:Thread, regCount:int):FunctionScope
		{
			var scope:FunctionScope = new FunctionScope();
			scope.prevContext = thread.getContext();
			scope.context = context.createChildContext();
			scope.defineAddress = address;
			scope.returnAddress = thread.ip;
			scope.regCount = regCount;
			return scope;
		}
	}
}