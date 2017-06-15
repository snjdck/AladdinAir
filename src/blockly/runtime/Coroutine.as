package blockly.runtime
{
	internal class Coroutine extends FunctionScope
	{
		internal var prev:Coroutine;
		internal var next:Coroutine;
		
		public function Coroutine(funcRef:FunctionObject)
		{
			super(funcRef);
		}
		
		internal function isExecuting(thread:Thread):Boolean
		{
			return resumeAddress < thread.ip && thread.ip < finishAddress;
		}
		
		internal function isFinish():Boolean
		{
			return resumeAddress >= finishAddress;
		}
		
		internal function getFinalCoroutine():Coroutine
		{
			var scope:Coroutine = this;
			while(scope.next != null)
				scope = scope.next;
			return scope;
		}
		
		internal function onYield(thread:Thread):void
		{
			resumeAddress = thread.ip;
			doReturn(thread);
		}
		
		override internal function onReturn(thread:Thread):void
		{
			resumeAddress = finishAddress;
			doReturn(thread);
			
			if(prev != null){
				thread.popScope();
				thread.pushScope(prev);
				prev.next = null;
				prev = null;
			}
		}
	}
}