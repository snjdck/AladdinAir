package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionObject
	{
		private var context:IScriptContext;
		private var argList:Array;
		private var addressBegin:int;
		private var addressEnd:int;
		
		internal var invokeCount:int;
		
		public function FunctionObject(context:IScriptContext, argList:Array, addressBegin:int, addressEnd:int)
		{
			this.context = context;
			this.argList = argList;
			this.addressBegin = addressBegin;
			this.addressEnd = addressEnd;
		}
		
		internal function createScope(valueList:Array):FunctionScope
		{
			var newContext:IScriptContext = context.createChildContext();
			for(var i:int=argList.length-1; i>=0; --i)
				newContext.newKey(argList[i], valueList[i]);
			var scope:FunctionScope = new FunctionScope(this);
			scope.nextContext = newContext;
			scope.defineAddress = addressBegin;
			scope.finishAddress = addressEnd;
			return scope;
		}
		
		internal function isRecursiveInvoke():Boolean
		{
			return invokeCount > 1;
		}
	}
}