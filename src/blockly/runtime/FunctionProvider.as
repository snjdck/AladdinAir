package blockly.runtime
{
	import snjdck.arithmetic.IScriptContext;
	import snjdck.arithmetic.impl.ScriptContext;

	public class FunctionProvider
	{
		private const context:IScriptContext = new ScriptContext();
		
		public function FunctionProvider(){}
		
		public function register(name:String, handler:Function, isAsync:Boolean=false):void
		{
			context.newKey(name, new FunctionObjectNative(handler, isAsync));
		}
		
		public function alias(name:String, newName:String):void
		{
			assert(context.hasKey(name, false));
			context.newKey(newName, context.getValue(name));
		}
		
		internal function execute(thread:Thread, name:String, argList:Array, retCount:int):void
		{
			if(context.hasKey(name, false)){
				var handler:FunctionObjectNative = context.getValue(name);
				handler.invoke(thread, argList, retCount > 0);
			}else{
				thread.requestCheckStack(retCount);
				onCallUnregisteredFunction(name, argList, retCount);
				if(!thread.isSuspend()){
					thread.checkStack();
				}
			}
		}
		
		protected function onCallUnregisteredFunction(name:String, argList:Array, retCount:int):void
		{
			trace("interpreter invoke method:", name, argList, retCount);
		}
		
		static public function CallFunction(thread:Thread, handler:Function, valueList:Array, hasValue:Boolean):void
		{
			var value:* = handler.apply(null, valueList);
			var isAsync:Boolean = value is Function;
			if(isAsync){
				thread.suspend();
				thread.requestCheckStack(hasValue ? 1 : 0);
				value(function(result:*=null):void{
					if(hasValue)
						thread.push(result);
					thread.resume();
				});
			}else if(hasValue){
				thread.push(value);
			}
		}
	}
}