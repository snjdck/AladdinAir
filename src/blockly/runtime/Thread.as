package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;

	public class Thread
	{
		private var codeList:Array;
		
		internal var ip:int;
		private var stack:Array = [];
		private var sp:int;
		internal var sc:int;
		
		private var _isSuspend:Boolean;
		
		private const _interruptSignal:Signal = new Signal();
		
		public function Thread(codeList:Array)
		{
			this.codeList = codeList;
		}
		
		public function get interruptSignal():ISignal
		{
			return _interruptSignal;
		}
		
		public function interrupt():void
		{
			ip = codeList.length;
			_interruptSignal.notify();
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
		}
		
		public function resume():void
		{
			_isSuspend = false;
		}
		
		public function isSuspend():Boolean
		{
			return _isSuspend;
		}
		
		public function push(value:Object):void
		{
			stack[sp++] = value;
		}
		
		internal function pop():*
		{
			return stack[--sp];
		}
	}
}