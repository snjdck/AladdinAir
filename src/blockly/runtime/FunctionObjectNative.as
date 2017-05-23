package blockly.runtime
{
	internal class FunctionObjectNative
	{
		private var handler:Function;
		private var isAsync:Boolean;
		
		public function FunctionObjectNative(handler:Function, isAsync:Boolean)
		{
			this.handler = handler;
			this.isAsync = isAsync;
		}
		
		internal function invoke(thread:Thread, valueList:Array, hasValue:Boolean):void
		{
			var value:* = handler.apply(null, valueList);
			if(isAsync){
				thread.suspend();
				thread.requestCheckStack(hasValue ? 1 : 0);
			}else if(hasValue){
				thread.push(value);
			}
		}
	}
}