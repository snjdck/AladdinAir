package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionScope
	{
		internal var prevScope:FunctionScope;
		internal var nextScope:FunctionScope;
		
		internal var prevCodeList:Array;
		internal var nextCodeList:Array;
		internal var prevContext:IScriptContext;
		internal var nextContext:IScriptContext;
		internal var prevFuncUserData:Array;
		internal var nextFuncUserData:Array;
		internal var defineAddress:int;
		internal var finishAddress:int;
		internal var returnAddress:int;
		internal var funcRef:FunctionObject;
		
		public function FunctionScope(funcRef:FunctionObject)
		{
			this.funcRef = funcRef;
		}
		
		internal function getFinalScope():FunctionScope
		{
			var scope:FunctionScope = this;
			while(scope.nextScope != null)
				scope = scope.nextScope;
			return scope;
		}
		
		internal function isExecuting(thread:Thread):Boolean
		{
			return defineAddress < thread.ip && thread.ip < finishAddress;
		}
		
		internal function isFinish():Boolean
		{
			return defineAddress >= finishAddress;
		}
	}
}