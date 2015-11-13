package blockly.runtime
{
	public class Interpreter
	{
		private const methodDict:Object = {};
		private var compiler:JsonCodeToAssembly;
		private var virtualMachine:VirtualMachine;
		
		public function Interpreter(functionProvider:FunctionProvider)
		{
			virtualMachine = new VirtualMachine(functionProvider);
			compiler = new JsonCodeToAssembly();
		}
		
		public function compile(blockList:Array):Array
		{
			return compiler.getTotalCode(blockList);
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