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
		internal var sc:int;
		private const valueStack:Array = [];
		private var sp:int;
		private const register:Array = [];
		private var regOffset:int;
		
		private var _isSuspend:Boolean;
		private var _suspendTimestamp:int;
		public var suspendUpdater:Object;
		
		private const _finishSignal:Signal = new Signal();
		
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
			_finishSignal.notify();
		}
		
		public function interrupt():void
		{
			ip = codeList.length;
		}
		
		public function isFinish():Boolean
		{
			return ip >= codeList.length;
		}
		
		internal function execNextCode(instructionExcetor:InstructionExector):void
		{
			assert(sp == sc);
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
			return valueStack[--sp];
		}
		
		internal function getSlot(index:int):*
		{
			return register[regOffset+index];
		}
		
		internal function setSlot(index:int, value:Object):void
		{
			register[regOffset+index] = value;
		}
		
		internal function increaseRegOffset(value:int):void
		{
			regOffset += value;
		}
		
		internal function updateSuspendState():void
		{
			call(suspendUpdater, this);
		}
		
		public function get timeElapsedSinceSuspend():int
		{
			return _isSuspend ? (getTimer() - _suspendTimestamp) : 0;
		}
	}
}