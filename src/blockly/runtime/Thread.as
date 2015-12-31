package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;
	import flash.utils.getTimer;
	
	import lambda.call;
	
	import snjdck.arithmetic.IScriptContext;

	final public class Thread
	{
		static public var EXEC_TIME:int = 4;
		
		private const scopeStack:Array = [];
		private var context:IScriptContext;
		
		private var codeList:Array;
		
		internal var ip:int;
		private var needCheckStack:Boolean;
		private var sc:int;
		private const valueStack:Array = [];
		private var sp:int;
		private const register:Array = [];
		private var regOffset:int;
		
		private var _isSuspend:Boolean;
		private var _suspendTimestamp:int;
		public var suspendUpdater:Object;
		
		private const _finishSignal:Signal = new Signal(Boolean);
		private var _finishFlag:Boolean;
		private var _interruptFlag:Boolean;
		private var _resumeOnNextFrameFlag:Boolean;
		
		public var userData:*;
		
		public function Thread(codeList:Array, context:IScriptContext)
		{
			this.codeList = codeList;
			this.context = context;
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
		
		internal function execNextCode(instructionExcetor:InstructionExector):Boolean
		{
			if(needCheckStack){
				assert(sp == sc, "function return count mismatch!");
				needCheckStack = false;
			}
			if(ip >= codeList.length){
				_finishFlag = true;
				return false;
			}
			var code:Array = codeList[ip];
			return instructionExcetor.execute(this, code[0], code.slice(1));
		}
		
		public function suspend():void
		{
			_isSuspend = true;
			_suspendTimestamp = getTimer();
		}
		
		public function resume():void
		{
			_isSuspend = false;
			suspendUpdater = null;
		}
		
		public function isSuspend():Boolean
		{
			return _isSuspend;
		}
		
		public function push(value:Object):void
		{
			valueStack[sp++] = value;
		}
		
		internal function pop():*
		{
			assert(sp > 0);
			return valueStack[--sp];
		}
		
		internal function getSlot(index:int):*
		{
			if(index < 0)
				return null;
			return register[regOffset+index];
		}
		
		internal function setSlot(index:int, value:Object):void
		{
			if(index < 0)
				return;
			register[regOffset+index] = value;
		}
		
		internal function updateSuspendState():void
		{
			if(_resumeOnNextFrameFlag || suspendUpdater == null)
				return;
			call(suspendUpdater, this);
		}
		
		public function get timeElapsedSinceSuspend():int
		{
			return _isSuspend ? (getTimer() - _suspendTimestamp) : 0;
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
		
		internal function onFrameBegin():void
		{
			if(_resumeOnNextFrameFlag){
				_isSuspend = false;
				_resumeOnNextFrameFlag = false;
			}
		}
		
		public function suspendUntilNextFrame():void
		{
			_isSuspend = true;
			_resumeOnNextFrameFlag = true;
		}
		
		internal function getContext():IScriptContext
		{
			return context;
		}
		
		internal function pushScope(scope:FunctionScope):void
		{
			scopeStack.push(scope);
			context = scope.context;
			regOffset += scope.regCount;
			ip = scope.defineAddress + 1;
		}
		
		internal function popScope():void
		{
			var scope:FunctionScope = scopeStack.pop();
			context = scope.prevContext;
			regOffset -= scope.regCount;
			ip = scope.returnAddress + 1;
		}
		
		internal function isRecursiveInvoke():Boolean
		{
			for(var i:int=scopeStack.length-1; i>0; --i){
				for(var j:int=i-1; j>=0; --j){
					var a:FunctionScope = scopeStack[i];
					var b:FunctionScope = scopeStack[j];
					if(a.defineAddress == b.defineAddress){
						return true;
					}
				}
			}
			return false;
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