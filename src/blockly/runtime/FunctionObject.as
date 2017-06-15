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
		
		public function FunctionObject(codeList:Array, context:IScriptContext, argList:Array, addressBegin:int, addressEnd:int, userData:Array)
		{
			this.codeList = codeList;
			this.context = context;
			this.argList = argList;
			this.addressBegin = addressBegin;
			this.addressEnd = addressEnd;
			this.ignoreYieldFlag = userData[0];
		}
		
		internal function createContext(valueList:Array):IScriptContext
		{
			var newContext:IScriptContext = context.createChild();
			for(var i:int=argList.length-1; i>=0; --i)
				newContext.newKey(argList[i], valueList[i]);
			return newContext;
		}
		
		internal function initScope(scope:FunctionScope, valueList:Array):void
		{
			scope.nextCodeList = codeList;
			scope.nextContext = createContext(valueList);
			scope.ignoreYieldFlag = ignoreYieldFlag;
			scope.resumeAddress = addressBegin;
			scope.finishAddress = addressEnd;
		}
	}
}