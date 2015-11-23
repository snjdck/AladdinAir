package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;
	import flash.utils.getTimer;
	
	import lambda.call;

	public class Thread
	{
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
		private var _interruptFlag:Boolean;
		
		public var userData:*;
		
		public function Thread(codeList:Array)
		{
			this.codeList = codeList;
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
			ip = codeList.length;
		}
		
		public function isFinish():Boolean
		{
			return ip >= codeList.length;
		}
		
		internal function execNextCode(instructionExcetor:InstructionExector):void
		{
			if(needCheckStack){
				assert(sp == sc, "function return count mismatch!");
				needCheckStack = false;
			}
			var code:Array = codeList[ip];
			instructionExcetor.execute(this, code[0], code.slice(1));
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
		
		internal function increaseRegOffset(value:int):void
		{
			regOffset += value;
			assert(regOffset >= 0);
		}
		
		internal function updateSuspendState():void
		{
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
	}
}