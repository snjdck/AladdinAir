package blockly.runtime
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;

	internal class VirtualMachine
	{
		private var instructionExector:InstructionExector;
		private const threadList:Vector.<Thread> = new Vector.<Thread>();
		private const timer:Shape = new Shape();
		
		public function VirtualMachine(functionProvider:FunctionProvider)
		{
			instructionExector = new InstructionExector(functionProvider);
			timer.addEventListener(Event.ENTER_FRAME, updateThreads);
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
		
		private function updateThreads(evt:Event):void
		{
			var canSuspend:Boolean;
			for(var index:int=0; index<threadList.length;){
				var thread:Thread = threadList[index];
				var endTime:int = getTimer() + Thread.EXEC_TIME;
				thread.onFrameBegin();
				for(;;){
					if(thread.isFinish()){
						threadList.splice(index, 1);
						thread.notifyFinish();
						break;
					}
					if(thread.isSuspend()){
						thread.updateSuspendState();
						++index;
						break;
					}
					canSuspend = thread.execNextCode(instructionExector);
					if(canSuspend && getTimer() >= endTime){
						thread.suspendUntilNextFrame();
					}
				}
			}
		}
	}
}