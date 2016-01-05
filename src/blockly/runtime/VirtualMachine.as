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
			timer.addEventListener(Event.ENTER_FRAME, onUpdateThreads);
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
		
		private function onUpdateThreads(evt:Event):void
		{
			notifyFrameBeginEvent();
			var endTime:int = getTimer() + Thread.EXEC_TIME;
			while(updateThreads() && getTimer() < endTime);
		}
		
		private function notifyFrameBeginEvent():void
		{
			for(var i:int=threadList.length-1; i >= 0; --i){
				var thread:Thread = threadList[i];
				thread.onFrameBegin();
			}
		}
		
		private function updateThreads():Boolean
		{
			var hasActiveThread:Boolean = false;
			out:for(var index:int=0; index<threadList.length;){
				var thread:Thread = threadList[index];
				for(;;){
					if(thread.isFinish()){
						threadList.splice(index, 1);
						thread.notifyFinish();
						continue out;
					}
					if(thread.isSuspend()){
						thread.updateSuspendState();
						break;
					}
					if(thread.execNextCode(instructionExector)){
						hasActiveThread = true;
						break;
					}
				}
				++index;
			}
			return hasActiveThread;
		}
	}
}