package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;

	internal class FunctionObject
	{
		private var context:IScriptContext;
		private var argList:Array;
		private var address:int;
		
		public function FunctionObject(context:IScriptContext, argList:Array, address:int)
		{
			this.context = context;
			this.argList = argList;
			this.address = address;
		}
		
		public function invoke(thread:Thread):void
		{
			thread.pushScope(context.createChildContext());
			for(var i:int=argList.length-1; i>=0; --i){
				thread.newVar(argList[i], thread.getSlot(i));
				thread.setSlot(i, null);
			}
			thread.ip = address;
		}
	}
}