package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;
	
	import snjdck.arithmetic.IScriptContext;
	import snjdck.arithmetic.impl.ScriptContext;

	final public class Thread
	{
		static public var EXEC_TIME:int = 0;
		static public var REDRAW_FLAG:Boolean = true;
		static public var Current:Thread;
		
		private var globalContext:IScriptContext;
		internal var context:IScriptContext;
		
		private var codeList:Array;
		private var virtualMachine:VirtualMachine;
		
		internal var ip:int;
		private var sc:int;
		private const valueStack:Vector.<Object> = new Vector.<Object>();
		private var sp:int = -1;
		
		private var _isSuspend:Boolean;
		public var suspendUpdater:Object;
		
		private const _finishSignal:Signal = new Signal(Boolean);
		private var _finishFlag:Boolean;
		private var _interruptFlag:Boolean;
		
		internal var runFlag:int;
		
		public var userData:*;
		
		public function Thread(virtualMachine:VirtualMachine, codeList:Array, globalContext:IScriptContext)
		{
			this.virtualMachine = virtualMachine;
			this.codeList = codeList;
			this.globalContext = globalContext;
			this.context = createContext();
		}
		
		private function createContext():IScriptContext
		{
			return globalContext != null ? globalContext.createChild() : new ScriptContext();
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
			runFlag = 0;
			_finishFlag = _interruptFlag = false;
			valueStack.length = ip = 0;
			sp = -1;
			context = createContext();
			resume();
			start();
		}
		
		internal function execNextCode(instructionExcetor:InstructionExector):void
		{
			if(ip < codeList.length){
				instructionExcetor.execute(codeList[ip]);
			}else{
				_finishFlag = true;
			}
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
			checkStack();
			_isSuspend = false;
			suspendUpdater = null;
		}
		
		public function isSuspend():Boolean
		{
			return _isSuspend;
		}
		
		public function push(value:Object):void
		{
			valueStack[++sp] = value;
		}
		
		internal function pop():*
		{
			return valueStack[sp--];
		}
		
		internal function peek():*
		{
			return valueStack[sp];
		}
		
		internal function put(value:Object):void
		{
			valueStack[sp] = value;
		}
		
		internal function updateSuspendState():void
		{
			if(suspendUpdater != null)
				$lambda.apply(suspendUpdater);
		}
		
		internal function requestCheckStack(count:int):void
		{
			sc = sp + count;
		}
		
		internal function checkStack():void
		{
			assert(sp == sc, "function return count mismatch!");
		}
		
		public function get resultValue():*
		{
			if(_interruptFlag)
				return;
			if(_finishFlag && sp == 0)
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
			scope.prevCodeList = codeList;
			scope.prevContext = context;
			scope.returnAddress = ip;
			codeList = scope.nextCodeList;
			context = scope.nextContext;
			scope.funcRef.invokeBegin(this);
			ip = scope.defineAddress + 1;
		}
		
		internal function popScope(needResume:Boolean):void
		{
			var scope:FunctionScope = pop();
			scope.defineAddress = needResume ? ip : scope.finishAddress;
			codeList = scope.prevCodeList;
			context = scope.prevContext;
			scope.funcRef.invokeEnd(this);
			ip = scope.returnAddress + 1;
			
			if(!needResume && scope.prevScope != null){
				scope.prevScope.nextScope = null;
				scope.prevScope = null;
			}
		}
		
		public function clone():Thread
		{
			return new Thread(virtualMachine, codeList, globalContext);
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
		
		internal function newFunction(argList:Array, addressEnd:int, userData:Array):FunctionObject
		{
			return new FunctionObject(codeList, context, argList, ip, addressEnd, userData);
		}
	}
}