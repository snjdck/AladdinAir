package blockly.runtime
{
	internal class Coroutine extends FunctionScope
	{
		private var prev:Coroutine;
		private var next:Coroutine;
		
		public function Coroutine(funcRef:FunctionObject)
		{
			super(funcRef);
		}
		
		internal function getHead():Coroutine
		{
			var scope:Coroutine = this;
			while(scope.prev != null)
				scope = scope.prev;
			return scope;
		}
		
		internal function getTail():Coroutine
		{
			var scope:Coroutine = this;
			while(scope.next != null)
				scope = scope.next;
			return scope;
		}
		
		internal function yieldFrom(other:Coroutine):void
		{
			other.prev = this;
			next = other;
		}
		
		internal function isFinish():Boolean
		{
			return resumeAddress >= finishAddress;
		}
		
		internal function onYield(thread:Thread):void
		{
			resumeAddress = thread.ip;
			getHead().doReturn(thread);
		}
		
		override internal function onReturn(thread:Thread):void
		{
			resumeAddress = finishAddress;
			doReturn(thread);
			
			if(prev != null){
				thread.pushScope(prev);
				prev.next = null;
				prev = null;
			}
		}
	}
}