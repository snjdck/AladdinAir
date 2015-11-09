package blockly.runtime
{

	public class Interpreter
	{
		private const opDict:Object = {};
		private const methodDict:Object = {};
		
		public function Interpreter()
		{
		}
		
		public function regOpHandler(op:String, handler:Function):void
		{
			opDict[op] = handler;
		}
		
		public function regMethodHandler(methodName:String, handler:Function):void
		{
			methodDict[methodName] = handler;
		}
		
		public function execOp(thread:Thread, op:String, argList:Array):void
		{
			var handler:Function = opDict[op];
			argList.unshift(thread);
			handler.apply(null, argList);
		}
		
		public function execMethod(thread:Thread, methodName:String, argList:Array):void
		{
			var handler:Function = methodDict[methodName];
			if(null == handler){
				trace("interpreter invoke method:", methodName, argList);
			}else{
				handler(thread, argList);
			}
		}
		
		public function newThread(codeList:Array):Thread
		{
			return new Thread(this, codeList);
		}
	}
}