package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;
	import snjdck.arithmetic.impl.ScriptContext;

	public class FunctionProvider
	{
		private const context:IScriptContext = new ScriptContext();
		
		public function FunctionProvider(){}
		
		public function register(name:String, value:Object):void
		{
			context.newKey(name, value);
		}
		
		public function alias(name:String, newName:String):void
		{
			assert(context.hasKey(name, false));
			context.newKey(newName, context.getValue(name));
		}
		
		internal function getContext():IScriptContext
		{
			return context;
		}
		
		internal function execute(thread:Thread, name:String, argList:Array):void
		{
			var handler:Function = context.getValue(name) as Function;
			if(null == handler){
				onCallUnregisteredFunction(thread, name, argList);
			}else{
				handler(thread, argList);
			}
		}
		
		protected function onCallUnregisteredFunction(thread:Thread, name:String, argList:Array):void
		{
			trace("interpreter invoke method:", name, argList);
		}
	}
}