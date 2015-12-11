package blockly.runtime
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import lambda.call;

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
		
		private function notifyFrameBeginEvent():void
		{
			for(var i:int=threadList.length-1; i>=0; --i){
				var thread:Thread = threadList[i];
				thread.onFrameBegin();
			}
		}
		
		private function updateThreads(evt:Event):void
		{
			notifyFrameBeginEvent();
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