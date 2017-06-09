package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionObject
	{
		private var codeList:Array;
		private var context:IScriptContext;
		private var argList:Array;
		private var addressBegin:int;
		private var addressEnd:int;
		private var ignoreYieldFlag:Boolean;
		private var invokeCount:int;
		
		public function FunctionObject(codeList:Array, context:IScriptContext, argList:Array, addressBegin:int, addressEnd:int, userData:Array)
		{
			this.codeList = codeList;
			this.context = context;
			this.argList = argList;
			this.addressBegin = addressBegin;
			this.addressEnd = addressEnd;
			this.ignoreYieldFlag = userData[0];
		}
		
		internal function createScope(valueList:Array):FunctionScope
		{
			var newContext:IScriptContext = context.createChild();
			for(var i:int=argList.length-1; i>=0; --i)
				newContext.newKey(argList[i], valueList[i]);
			var scope:FunctionScope = new FunctionScope(this);
			scope.nextCodeList = codeList;
			scope.nextContext = newContext;
			scope.defineAddress = addressBegin;
			scope.finishAddress = addressEnd;
			return scope;
		}
		
		internal function invokeBegin(thread:Thread):void
		{
			++invokeCount;
			if(ignoreYieldFlag)
				++thread.runFlag;
		}
		
		internal function invokeEnd(thread:Thread):void
		{
			--invokeCount;
			if(ignoreYieldFlag)
				--thread.runFlag;
		}
		
		internal function isRecursiveInvoke():Boolean
		{
			return invokeCount > 1;
		}
	}
}