package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionScope
	{
		public var prevContext:IScriptContext;
		public var nextContext:IScriptContext;
		public var defineAddress:int;
		public var returnAddress:int;
		public var regCount:int;
		private var funcRef:FunctionObject;
		
		public function FunctionScope(funcRef:FunctionObject)
		{
			this.funcRef = funcRef;
		}
		
		public function onInvoke():void
		{
			++funcRef.invokeCount;
		}
		
		public function onReturn():void
		{
			--funcRef.invokeCount;
		}
	}
}