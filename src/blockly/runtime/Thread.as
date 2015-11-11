package blockly.runtime
{
	import flash.signals.Signal;

	public class Thread
	{
		private var interpreter:Interpreter;
		private var codeList:Array;
		
		public var ip:int = 0;
		private var stack:Array = [];
		private var sp:int = 0;
		
		private var _isSuspend:Boolean;
		
		public const stopedSignal:Signal = new Signal();
		
		public function Thread(interpreter:Interpreter, codeList:Array)
		{
			this.interpreter = interpreter;
			this.codeList = codeList;
		}
		
		public function interrupt():void
		{
			stopedSignal.notify();
		}
		
		public function start():void
		{
			ip = 0;
			sp = 0;
			resume();
		}
		
		public function isFinish():Boolean
		{
			return ip >= codeList.length;
		}
		
		public function execNextCode():void
		{
			var code:Array = codeList[ip];
			interpreter.execOp(this, code[0], code.slice(1));
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
		
		public function pop():*
		{
			return stack[--sp];
		}
		
		public function execMethod(methodName:String, argList:Array):void
		{
			interpreter.execMethod(this, methodName, argList);
		}
	}
}