package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionObject
	{
		private var context:IScriptContext;
		public var address:int;
		
		public function FunctionObject(context:IScriptContext, address:int)
		{
			this.context = context;
			this.address = address;
		}
		
		public function createContext():IScriptContext
		{
			return context.createChildContext();
		}
	}
}