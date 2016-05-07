package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;
	import flash.utils.getTimer;
	
	import lambda.call;
	
	import snjdck.arithmetic.IScriptContext;
	import snjdck.arithmetic.impl.ScriptContext;

	final public class Thread
	{
		static public var EXEC_TIME:int = 0;
		static public var REDRAW_FLAG:Boolean = true;
		
		internal var context:IScriptContext;
		
		private var codeList:Array;
		
		internal var ip:int;
		private var needCheckStack:Boolean;
		private var sc:int;
		private const valueStack:Array = [];
		private var sp:int;
		
		private var _isSuspend:Boolean;
		private var _suspendTimestamp:int;
		public var suspendUpdater:Object;
		
		private const _finishSignal:Signal = new Signal(Boolean);
		private var _finishFlag:Boolean;
		private var _interruptFlag:Boolean;
		private var _resumeOnNextFrameFlag:Boolean;
		private var _redrawFlag:Boolean;
		
		public var userData:*;
		
		public function Thread(codeList:Array)
		{
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
			_redrawFlag = false;
		}
		
		public function suspendUntilNextFrame():void
		{
			_isSuspend = true;
			_resumeOnNextFrameFlag = true;
		}
		
		public function requestRedraw():void
		{
			if(REDRAW_FLAG){
				_redrawFlag = true;
			}
		}
		
		public function needRedraw():Boolean
		{
			return _redrawFlag;
		}
		
		internal function pushScope(scope:FunctionScope, offset:int=0):void
		{
			push(scope);
			++scope.funcRef.invokeCount;
			scope.prevContext = context;
			scope.returnAddress = ip;
			context = scope.nextContext;
			ip = scope.defineAddress + 1 + offset;
		}
		
		internal function popScope(needResume:Boolean):void
		{
			var scope:FunctionScope = pop();
			--scope.funcRef.invokeCount;
			scope.ip = (needResume ? ip : scope.finishAddress) - scope.defineAddress;
			context = scope.prevContext;
			ip = scope.returnAddress + 1;
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