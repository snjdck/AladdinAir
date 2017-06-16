package blockly.runtime
{
	internal class Coroutine extends FunctionScope
	{
		internal var yieldFrom:Coroutine;
		
		public function Coroutine(funcRef:FunctionObject)
		{
			super(funcRef);
		}
		
		internal function get innermost():Coroutine
		{
			var scope:Coroutine = this;
			while(scope.yieldFrom != null)
				scope = scope.yieldFrom;
			return scope;
		}
		
		private function removeInnermost():void
		{
			var scope:Coroutine = this;
			while(scope.yieldFrom.yieldFrom != null)
				scope = scope.yieldFrom;
			scope.yieldFrom = null;
		}
		
		internal function isFinish():Boolean
		{
			return resumeAddress >= finishAddress;
		}
		
		internal function onYield(thread:Thread):void
		{
			innermost.resumeAddress = thread.ip;
			doReturn(thread);
		}
		
		override internal function onReturn(thread:Thread):void
		{
			innermost.resumeAddress = finishAddress;
			innermost.doReturn(thread);
			if(yieldFrom != null){
				thread.pushScope(this);
				removeInnermost();
			}
		}
	}
}