package blockly.runtime
{
	import flash.utils.getTimer;

	internal class VirtualMachine
	{
		private var instructionExector:InstructionExector;
		private const threadList:Vector.<Thread> = new Vector.<Thread>();
		
		internal var redrawFlag:Boolean;
		internal var yieldFlag:Boolean;
		internal var waitFlag:Boolean;
		
		private var activeFlag:Boolean;
		
		public function VirtualMachine(functionProvider:FunctionProvider)
		{
			instructionExector = new InstructionExector(functionProvider);
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
		
		public function onTick():void
		{
			if(threadList.length <= 0){
				return;
			}
			redrawFlag = false;
			var timeEnd:int = getTimer() + Thread.EXEC_TIME;
			while(updateThreads() && getTimer() < timeEnd);
		}
		
		private function updateThreads():Boolean
		{
			activeFlag = false;
			for each(var thread:Thread in threadList)
				updateThread(thread);
			Thread.Current = null;
			removeFinishedThreads();
			return !redrawFlag && activeFlag;
		}
		
		private function updateThread(thread:Thread):void
		{
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
				if(!yieldFlag){
					continue;
				}
				if(thread.funcUserData && thread.funcUserData[0]){
					yieldFlag = false;
				}else{
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
		
		public function execute(thread:Thread):void
		{
			var prevThread:Thread = Thread.Current;
			Thread.Current = thread;
			while(!thread.isFinish()){
				thread.execNextCode(instructionExector);
			}
			Thread.Current = prevThread;
		}
	}
}