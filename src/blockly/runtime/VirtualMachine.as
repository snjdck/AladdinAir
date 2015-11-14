package blockly.runtime
{
	import flash.utils.getTimer;
	import flash.utils.setInterval;

	internal class VirtualMachine
	{
		private var instructionExector:InstructionExector;
		private const threadList:Array = [];
		
		public function VirtualMachine(functionProvider:FunctionProvider)
		{
			instructionExector = new InstructionExector(functionProvider);
			setInterval(updateThreads, 0);
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
						continue;
					}
					if(thread.isSuspend()){
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
			assert(thread.sc == 1);
			return thread.pop();
		}
	}
}