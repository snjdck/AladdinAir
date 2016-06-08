package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;
	import snjdck.arithmetic.impl.ScriptContext;

	public class FunctionProvider
	{
		private const context:IScriptContext = new ScriptContext();
		
		public function FunctionProvider(){}
		
		public function register(name:String, handler:Function, hasValue:Boolean=false, isAsync:Boolean=false):void
		{
			context.newKey(name, new FunctionObjectNative(handler, hasValue, isAsync));
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
		
		internal function execute(name:String, argList:Array, retCount:int):void
		{
			if(context.hasKey(name, false)){
				var handler:FunctionObjectNative = context.getValue(name);
				handler.invoke(argList);
			}else{
				onCallUnregisteredFunction(name, argList, retCount);
			}
		}
		
		protected function onCallUnregisteredFunction(name:String, argList:Array, retCount:int):void
		{
			trace("interpreter invoke method:", name, argList, retCount);
		}
	}
}