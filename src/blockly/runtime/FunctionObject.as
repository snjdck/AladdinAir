package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionObject
	{
		private var context:IScriptContext;
		private var argList:Array;
		private var address:int;
		
		internal var invokeCount:int;
		
		public function FunctionObject(context:IScriptContext, argList:Array, address:int)
		{
			this.context = context;
			this.argList = argList;
			this.address = address;
		}
		
		internal function createScope(thread:Thread, valueList:Array):FunctionScope
		{
			var newContext:IScriptContext = context.createChildContext();
			for(var i:int=argList.length-1; i>=0; --i)
				newContext.newKey(argList[i], valueList[i]);
			var scope:FunctionScope = new FunctionScope(this);
			scope.prevContext = thread.getContext();
			scope.nextContext = newContext;
			scope.defineAddress = address;
			scope.returnAddress = thread.ip;
			return scope;
		}
		
		internal function isRecursiveInvoke():Boolean
		{
			return invokeCount > 1;
		}
	}
}