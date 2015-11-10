package blockly.runtime
{
	import flash.utils.getTimer;
	import flash.utils.setInterval;

	public class Interpreter
	{
		private const opDict:Object = {};
		private const methodDict:Object = {};
		private const threadList:Array = [];
		
		public function Interpreter()
		{
			setInterval(updateThreads, 0);
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
			var thread:Thread = new Thread(this, codeList);
			threadList.push(thread);
			return thread;
		}
		
		public function stopAllThreads():void
		{
			while(threadList.length > 0){
				var thread:Thread = threadList.pop();
				thread.interrupt();
			}
		}
		
		public function updateThreads():void
		{
			var endTime:int = getTimer() + 10;
			var isRunning:Boolean = true;
			while(isRunning && getTimer() < endTime){
				isRunning = false;
				for(var i:int=threadList.length-1; i>=0; --i){
					var thread:Thread = threadList[i];
					if(thread.isFinish()){
						threadList.splice(i, 1);
						continue;
					}
					if(thread.isSuspend()){
						continue;
					}
					isRunning = true;
					thread.execNextCode();
				}
			}
		}
	}
}