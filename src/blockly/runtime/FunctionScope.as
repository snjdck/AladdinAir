package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionScope
	{
		internal var prevScope:FunctionScope;
		internal var nextScope:FunctionScope;
		
		internal var tailRecursion:FunctionScope;
		
		internal var prevCodeList:Array;
		internal var nextCodeList:Array;
		internal var prevContext:IScriptContext;
		internal var nextContext:IScriptContext;
		internal var defineAddress:int;
		internal var finishAddress:int;
		internal var returnAddress:int;
		
		internal var ignoreYieldFlag:Boolean;
		internal var prevRunFlag:int;
		
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
		
		internal function join(other:FunctionScope):void
		{
			prevCodeList = other.prevCodeList;
			prevContext = other.prevContext;
			prevRunFlag = other.prevRunFlag;
			returnAddress = other.returnAddress;
			tailRecursion = other;
		}
		
		internal function apply(thread:Thread):void
		{
			prevCodeList = thread.codeList;
			prevContext = thread.context;
			prevRunFlag = thread.runFlag;
			returnAddress = thread.ip;
			
			thread.codeList = nextCodeList;
			thread.context = nextContext;
			thread.ip = defineAddress + 1;
			if(ignoreYieldFlag){
				++thread.runFlag;
			}
		}
		
		internal function revert(thread:Thread):void
		{
			thread.codeList = prevCodeList;
			thread.context = prevContext;
			thread.runFlag = prevRunFlag;
			thread.ip = returnAddress + 1;
		}
	}
}