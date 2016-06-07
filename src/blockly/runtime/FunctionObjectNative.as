package blockly.runtime
{
	internal class FunctionObjectNative
	{
		private var handler:Function;
		
		public function FunctionObjectNative(handler:Function)
		{
			this.handler = handler;
		}
		
		internal function invoke(valueList:Array):void
		{
			handler.apply(null, valueList);
		}
	}
}