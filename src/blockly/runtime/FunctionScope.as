package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionScope
	{
		private var tailRecursion:FunctionScope;
		
		internal var prevCodeList:Array;
		internal var nextCodeList:Array;
		internal var prevContext:IScriptContext;
		internal var nextContext:IScriptContext;
		internal var resumeAddress:int;
		internal var finishAddress:int;
		internal var returnAddress:int;
		
		internal var ignoreYieldFlag:Boolean;
		internal var prevRunFlag:int;
		
		private var funcRef:FunctionObject;
		
		public function FunctionScope(funcRef:FunctionObject)
		{
			this.funcRef = funcRef;
		}
		
		internal function join(other:FunctionScope):void
		{
			tailRecursion = other;
			prevCodeList = other.prevCodeList;
			prevContext = other.prevContext;
			prevRunFlag = other.prevRunFlag;
			returnAddress = other.returnAddress;
		}
		
		internal function doInvoke(thread:Thread):void
		{
			prevCodeList = thread.codeList;
			prevContext = thread.context;
			prevRunFlag = thread.runFlag;
			returnAddress = thread.ip;
			
			thread.codeList = nextCodeList;
			thread.context = nextContext;
			thread.ip = resumeAddress + 1;
			if(ignoreYieldFlag){
				++thread.runFlag;
			}
		}
		
		protected function doReturn(thread:Thread):void
		{
			thread.codeList = prevCodeList;
			thread.context = prevContext;
			thread.runFlag = prevRunFlag;
			thread.ip = returnAddress + 1;
		}
		
		internal function hasInvoked(funcRef:FunctionObject):Boolean
		{
			var scope:FunctionScope = this;
			do{
				if(scope.funcRef == funcRef)
					return true;
				scope = scope.tailRecursion;
			}while(scope != null);
			return false;
		}
		
		internal function onReturn(thread:Thread):void
		{
			doReturn(thread);
		}
	}
}