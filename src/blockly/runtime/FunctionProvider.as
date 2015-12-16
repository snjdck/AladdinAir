package blockly.runtime
{
	public class FunctionProvider
	{
		private const methodDict:Object = {};
		
		public function FunctionProvider(){}
		
		public function register(name:String, handler:Function):void
		{
			methodDict[name] = handler;
		}
		
		public function alias(name:String, newName:String):void
		{
			assert(methodDict[name] != null);
			methodDict[newName] = methodDict[name];
		}
		
		internal function execute(thread:Thread, name:String, argList:Array):void
		{
			var handler:Function = methodDict[name];
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