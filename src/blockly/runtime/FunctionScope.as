package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionScope
	{
		public var prevContext:IScriptContext;
		public var context:IScriptContext;
		public var defineAddress:int;
		public var returnAddress:int;
		public var regCount:int;
		
		public function FunctionScope(){}
	}
}