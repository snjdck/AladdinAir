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
		
		private var globalContext:IScriptContext;
		internal var context:IScriptContext;
		
		private var codeList:Array;
		private var virtualMachine:VirtualMachine;
		
		internal var ip:int;
		private var needCheckStack:Boolean;
		private var sc:int;
		private const valueStack:Vector.<Object> = new Vector.<Object>();
		private var sp:int = -1;
		
		private var _isSuspend:Boolean;
		public var suspendUpdater:Object;
		
		private const _finishSignal:Signal = new Signal(Boolean);
		private var _finishFlag:Boolean;
		private var _interruptFlag:Boolean;
		
		internal var funcUserData:Array;
		
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
			_finishFlag = _interruptFlag = needCheckStack = false;
			valueStack.length = ip = 0;
			sp = -1;
			context = createContext();
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
			if(needCheckStack)
				assert(sp < sc);
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
			++scope.funcRef.invokeCount;
			scope.prevCodeList = codeList;
			scope.prevContext = context;
			scope.prevFuncUserData = funcUserData;
			scope.returnAddress = ip;
			codeList = scope.nextCodeList;
			context = scope.nextContext;
			funcUserData = scope.nextFuncUserData;
			ip = scope.defineAddress + 1;
		}
		
		internal function popScope(needResume:Boolean):void
		{
			var scope:FunctionScope = pop();
			--scope.funcRef.invokeCount;
			scope.defineAddress = needResume ? ip : scope.finishAddress;
			codeList = scope.prevCodeList;
			context = scope.prevContext;
			funcUserData = scope.prevFuncUserData;
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