package blockly.runtime
{
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import lambda.call;

	internal class VirtualMachine
	{
		private var instructionExector:InstructionExector;
		private const threadList:Vector.<Thread> = new Vector.<Thread>();
		
		public function VirtualMachine(functionProvider:FunctionProvider)
		{
			instructionExector = new InstructionExector(functionProvider);
			setInterval(updateThreads, 0);
		}
		
		public function getThreadCount():uint
		{
			return threadList.length;
		}
		
		public function getCopyOfThreadList():Vector.<Thread>
		{
			return threadList.slice();
		}
		
		public function startThread(thread:Thread):void
		{
			if(threadList.indexOf(thread) < 0){
				threadList.push(thread);
			}
		}
		
		public function stopAllThreads():void
		{
			while(threadList.length > 0){
				var thread:Thread = threadList.pop();
				thread.interrupt();
			}
		}
		
		private function updateThreads():void
		{
			var endTime:int = getTimer() + 10;
			var isRunning:Boolean = true;
			while(isRunning && getTimer() < endTime){
				isRunning = false;
				for(var i:int=threadList.length-1; i>=0; --i){
					var thread:Thread = threadList[i];
					if(thread.isFinish()){
						threadList.splice(i, 1);
						thread.notifyFinish();
						continue;
					}
					if(thread.isSuspend()){
						thread.updateSuspendState();
						continue;
					}
					isRunning = true;
					thread.execNextCode(instructionExector);
				}
			}
		}
		
		public function calculate(thread:Thread):*
		{
			while(!thread.isFinish()){
				thread.execNextCode(instructionExector);
			}
			return thread.pop();
		}
		
		public function calculateAsynchronous(thread:Thread, handler:Object):void
		{
			thread.finishSignal.add(function(interruptFlag:Boolean):void{
				if(interruptFlag){
					call(handler, false, null);
				}else{
					call(handler, true, thread.pop());
				}
			}, true);
			startThread(thread);
		}
	}
}