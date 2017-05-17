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
		
		internal var redrawFlag:Boolean;
		internal var yieldFlag:Boolean;
		internal var waitFlag:Boolean;
		
		private var activeFlag:Boolean;
		
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
			for each(var thread:Thread in threadList){
				thread.interrupt();
			}
		}
		
		private function onUpdateThreads(evt:Event):void
		{
			if (threadList.length <= 0) return;
//			trace("== event loop begin");
			redrawFlag = false;
			var endTime:int = getTimer() + Thread.EXEC_TIME;
			while(updateThreads() && getTimer() < endTime);
		}
		
		private function updateThreads():Boolean
		{
//			trace("-- thread loop begin");
			activeFlag = false;
			//let new threads create in exec run in next loop
			for(var i:int=0, n:int=threadList.length; i<n; ++i)
				updateThread(threadList[i]);
			Thread.Current = null;
			removeFinishedThreads();
			return !redrawFlag && activeFlag;
		}
		
		private function updateThread(thread:Thread):void
		{
//			trace("** step thread");
			Thread.Current = thread;
			yieldFlag = waitFlag = false;
			for(;;){
				if(thread.isFinish()){
					return;
				}
				if(thread.isSuspend()){
					thread.updateSuspendState();
					return;
				}
				thread.execNextCode(instructionExector);
				if(yieldFlag){
					break;
				}
			}
			if(!waitFlag){
				activeFlag = true;
			}
		}
		
		private function removeFinishedThreads():void
		{
			var index:int = 0;
			while(index < threadList.length){
				var thread:Thread = threadList[index];
				if(thread.isFinish()){
					threadList.removeAt(index);
					thread.notifyFinish();
				}else{
					++index;
				}
			}
		}
	}
}