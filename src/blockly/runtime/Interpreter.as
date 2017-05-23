package blockly.runtime
{
	import flash.display.Shape;
	import flash.events.Event;
	
	import snjdck.arithmetic.IScriptContext;

	public class Interpreter
	{
		private const timer:Shape = new Shape();
		
		private var virtualMachine:VirtualMachine;
		private var compiler:JsonCodeToAssembly;
		private var deadCodeCleaner:DeadCodeCleaner;
		private var optimizer:AssemblyOptimizer;
		private var conditionCalculater:ConditionCalculater;
		private var printer:CodeListPrinter;
		private var functionProvider:FunctionProvider;
		private var profiler:CodeProfiler;
		
		public function Interpreter(functionProvider:FunctionProvider)
		{
			virtualMachine = new VirtualMachine(functionProvider);
			compiler = new JsonCodeToAssembly();
			conditionCalculater = new ConditionCalculater();
			optimizer = new AssemblyOptimizer();
			deadCodeCleaner = new DeadCodeCleaner();
			printer = new CodeListPrinter();
			profiler = new CodeProfiler();
			this.functionProvider = functionProvider;
			timer.addEventListener(Event.ENTER_FRAME, __onEnterFrame);
		}
		
		private function __onEnterFrame(evt:Event):void
		{
			if(virtualMachine.getThreadCount() <= 0){
				return;
			}
			if(functionProvider.profiler != null){
				profiler.reset();
				virtualMachine.onTick();
				profiler.print();
			}else{
				virtualMachine.onTick();
			}
		}
		
		public function compile(blockList:Array):Array
		{
			var codeList:Array = compiler.translate(blockList);
			conditionCalculater.calculate(codeList);
			optimizer.optimize(codeList);
			deadCodeCleaner.clean(codeList);
			return codeList;
		}
		
		public function execute(blockList:Array, globalContext:IScriptContext=null):Thread
		{
			return executeAssembly(compile(blockList), globalContext);
		}
		
		public function executeAssembly(codeList:Array, globalContext:IScriptContext=null):Thread
		{
			var thread:Thread = new Thread(virtualMachine, codeList, globalContext);
			virtualMachine.startThread(thread);
			return thread;
		}
		
		public function executeAssemblySynchronously(codeList:Array):IScriptContext
		{
			var thread:Thread = new Thread(virtualMachine, codeList, null);
			virtualMachine.execute(thread);
			return thread.context;
		}
		
		public function executeSynchronously(blockList:Array):IScriptContext
		{
			return executeAssemblySynchronously(compile(blockList));
		}
		
		public function stopAllThreads():void
		{
			virtualMachine.stopAllThreads();
		}
		
		public function getCopyOfThreadList():Vector.<Thread>
		{
			return virtualMachine.getCopyOfThreadList();
		}
		
		public function getThreadCount():uint
		{
			return virtualMachine.getThreadCount();
		}
		
		public function castCodeListToString(codeList:Array):String
		{
			return printer.castCodeListToString(codeList);
		}
		
		public function enableProfiler():void
		{
			functionProvider.profiler = profiler;
		}
	}
}