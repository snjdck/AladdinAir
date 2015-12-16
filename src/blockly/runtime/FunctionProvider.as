package blockly.runtime
{
	public class FunctionProvider
	{
		private const varDict:Object = {};
		
		public function FunctionProvider(){}
		
		public function register(name:String, value:Object):void
		{
			varDict[name] = value;
		}
		
		public function alias(name:String, newName:String):void
		{
			assert(varDict[name] != null);
			varDict[newName] = varDict[name];
		}
		
		internal function hasVar(name:String):Boolean
		{
			return name in varDict;
		}
		
		internal function getVar(name:String):Object
		{
			return varDict[name];
		}
		
		internal function execute(thread:Thread, name:String, argList:Array):void
		{
			var handler:Function = varDict[name] as Function;
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