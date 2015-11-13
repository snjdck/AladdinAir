package blockly.runtime
{
	public class Interpreter
	{
		private const methodDict:Object = {};
		private var virtualMachine:VirtualMachine;
		private var compiler:JsonCodeToAssembly;
		private var deadCodeCleaner:DeadCodeCleaner;
		private var optimizer:AssemblyOptimizer;
		
		public function Interpreter(functionProvider:FunctionProvider)
		{
			virtualMachine = new VirtualMachine(functionProvider);
			compiler = new JsonCodeToAssembly();
			deadCodeCleaner = new DeadCodeCleaner();
			optimizer = new AssemblyOptimizer();
		}
		
		public function compile(blockList:Array):Array
		{
			var codeList:Array = compiler.getTotalCode(blockList);
			codeList = deadCodeCleaner.clean(codeList);
			optimizer.optimize(codeList);
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
	}
}