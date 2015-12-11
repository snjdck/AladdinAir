package blockly.runtime
{
	public class Interpreter
	{
		private var virtualMachine:VirtualMachine;
		private var compiler:JsonCodeToAssembly;
		private var deadCodeCleaner:DeadCodeCleaner;
		private var optimizer:AssemblyOptimizer;
		private var conditionCalculater:ConditionCalculater;
		
		public function Interpreter(functionProvider:FunctionProvider)
		{
			virtualMachine = new VirtualMachine(functionProvider);
			compiler = new JsonCodeToAssembly();
			conditionCalculater = new ConditionCalculater(this, functionProvider);
			optimizer = new AssemblyOptimizer();
			deadCodeCleaner = new DeadCodeCleaner();
		}
		
		public function compile(blockList:Array):Array
		{
			var codeList:Array = compiler.translate(blockList);
			conditionCalculater.calculate(codeList);
			optimizer.optimize(codeList);
			deadCodeCleaner.clean(codeList);
			return codeList;
		}
		
		public function execute(blockList:Array):Thread
		{
			return executeAssembly(compile(blockList));
		}
		
		public function executeAssembly(codeList:Array):Thread
		{
			var thread:Thread = new Thread(codeList);
			virtualMachine.startThread(thread);
			return thread;
		}
		
		public function stopAllThreads():void
		{
			virtualMachine.stopAllThreads();
		}
		
		public function calculateAssembly(codeList:Array):*
		{
			return virtualMachine.calculate(new Thread(codeList));
		}
		
		public function calculateAssemblyAsynchronous(codeList:Array, handler:Object):void
		{
			virtualMachine.calculateAsynchronous(new Thread(codeList), handler);
		}
		
		public function getCopyOfThreadList():Vector.<Thread>
		{
			return virtualMachine.getCopyOfThreadList();
		}
		
		public function getThreadCount():uint
		{
			return virtualMachine.getThreadCount();
		}
	}
}