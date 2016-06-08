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
		
		internal function invoke(valueList:Array, hasValue:Boolean):void
		{
			var thread:Thread = Thread.Current;
			var value:* = handler.apply(null, valueList);
			if(isAsync){
				thread.suspend();
			}else if(hasValue){
				thread.push(value);
			}
		}
	}
}