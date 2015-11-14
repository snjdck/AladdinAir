package blockly.runtime
{
	public class FunctionProvider
	{
		private const methodDict:Object = {};
		private const nativeDict:Object = {};
		
		public function FunctionProvider()
		{
		}
		
		public function register(name:String, handler:Function):void
		{
			methodDict[name] = handler;
		}
		
		public function registerNative(name:String, handler:Function):void
		{
			register(name, handler);
			nativeDict[name] = true;
		}
		
		public function execute(thread:Thread, name:String, argList:Array):void
		{
			var handler:Function = methodDict[name];
			if(null == handler){
				trace("interpreter invoke method:", name, argList);
			}else{
				handler(thread, argList);
			}
		}
		
		internal function isNativeFunction(name:String):Boolean
		{
			return Boolean(nativeDict[name]);
		}
	}
}