package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionScope
	{
		internal var prevContext:IScriptContext;
		internal var nextContext:IScriptContext;
		internal var defineAddress:int;
		internal var finishAddress:int;
		internal var returnAddress:int;
		internal var funcRef:FunctionObject;
		
		internal var ip:int;
		
		public function FunctionScope(funcRef:FunctionObject)
		{
			this.funcRef = funcRef;
		}
		
		internal function isExecuting(thread:Thread):Boolean
		{
			return defineAddress < thread.ip && thread.ip < finishAddress;
		}
	}
}