package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;
	
	import lambda.apply;
	
	import snjdck.arithmetic.IScriptContext;
	import snjdck.arithmetic.impl.ScriptContext;

	final public class Thread
	{
		static public var EXEC_TIME:int = 0;
		static public var REDRAW_FLAG:Boolean = true;
		static public var Current:Thread;
		
		internal var context:IScriptContext;
		
		private var codeList:Array;
		private var virtualMachine:VirtualMachine;
		
		internal var ip:int;
		private var needCheckStack:Boolean;
		private var sc:int;
		private const valueStack:Array = [];
		private var sp:int;
		
		private var _isSuspend:Boolean;
		public var suspendUpdater:Object;
		
		private const _finishSignal:Signal = new Signal(Boolean);
		private var _finishFlag:Boolean;
		private var _interruptFlag:Boolean;
		
		public var userData:*;
		
		public function Thread(virtualMachine:VirtualMachine, codeList:Array)
		{
			this.virtualMachine = virtualMachine;
			this.codeList = codeList;
			this.context = new ScriptContext();
		}
		
		public function get finishSignal():ISignal
		{
			return _finishSignal;
		}
		
		internal function notifyFinish():void
		{
			_finishSignal.notify(_interruptFlag);
		}
		
		public function interrupt():void
		{
			_interruptFlag = true;
			_finishFlag = true;
		}
		
		public function isFinish():Boolean
		{
			return _finishFlag;
		}
		
		public function start():void
		{
			virtualMachine.startThread(this);
		}
		
		public function restart():void
		{
			_finishFlag = _interruptFlag = needCheckStack = false;
			valueStack.length = ip = sp = 0;
			context = new ScriptContext();
			resume();
			start();
		}
		
		internal function execNextCode(instructionExcetor:InstructionExector):void
		{
			if(needCheckStack){
				assert(sp == sc, "function return count mismatch!");
				needCheckStack = false;
			}
			if(ip >= codeList.length){
				_finishFlag = true;
				return;
			}
			instructionExcetor.execute(codeList[ip]);
		}
		
		public function yield(waitFlag:Boolean=true):void
		{
			virtualMachine.yieldFlag = true;
			virtualMachine.waitFlag ||= waitFlag;
		}
		
		public function suspend():void
		{
			_isSuspend = true;
		}
		
		public function resume():void
		{
			if(needCheckStack)
				assert(sp == sc);
			_isSuspend = false;
			suspendUpdater = null;
		}
		
		public function isSuspend():Boolean
		{
			return _isSuspend;
		}
		
		public function push(value:Object):void
		{
			if(needCheckStack && sp >= sc)
				return;
			valueStack[sp++] = value;
		}
		
		internal function pop():*
		{
			assert(sp > 0);
			return valueStack[--sp];
		}
		
		internal function updateSuspendState():void
		{
			if(suspendUpdater != null)
				lambda.apply(suspendUpdater);
		}
		
		internal function requestCheckStack(count:int):void
		{
			needCheckStack = true;
			sc = sp + count;
		}
		
		public function get resultValue():*
		{
			if(_interruptFlag)
				return;
			if(_finishFlag && sp == 1)
				return valueStack[0];
		}
		
		public function requestRedraw():void
		{
			if(REDRAW_FLAG){
				virtualMachine.redrawFlag = true;
			}
		}
		
		internal function pushScope(scope:FunctionScope):void
		{
			push(scope);
			++scope.funcRef.invokeCount;
			scope.prevContext = context;
			scope.returnAddress = ip;
			context = scope.nextContext;
			ip = scope.defineAddress + 1;
		}
		
		internal function popScope(needResume:Boolean):void
		{
			var scope:FunctionScope = pop();
			--scope.funcRef.invokeCount;
			scope.defineAddress = needResume ? ip : scope.finishAddress;
			context = scope.prevContext;
			ip = scope.returnAddress + 1;
			
			if(!needResume && scope.prevScope != null){
				scope.prevScope.nextScope = null;
				scope.prevScope = null;
			}
		}
		
		public function clone():Thread
		{
			return new Thread(virtualMachine, codeList);
		}
		
		public function newVar(varName:String, varValue:Object):void
		{
			context.newKey(varName, varValue);
		}
		
		public function getVar(varName:String):*
		{
			return context.getValue(varName);
		}
		
		public function setVar(varName:String, value:Object):void
		{
			context.setValue(varName, value);
		}
	}
}