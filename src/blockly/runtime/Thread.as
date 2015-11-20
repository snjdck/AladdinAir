package blockly.runtime
{
	import flash.signals.ISignal;
	import flash.signals.Signal;

	public class Thread
	{
		private var codeList:Array;
		
		internal var ip:int;
		internal var sc:int;
		private const valueStack:Vector.<Object> = new Vector.<Object>();
		private var sp:int;
		
		private const register:Vector.<int> = new Vector.<int>(8, true);
		private const varDictStack:Array = [];
		
		private var _isSuspend:Boolean;
		
		private const _interruptSignal:Signal = new Signal();
		
		public var userData:*;
		
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
			valueStack[sp++] = value;
		}
		
		internal function pop():*
		{
			return valueStack[--sp];
		}
		
		internal function loadSlot(index:int):void
		{
			push(register[index]);
		}
		
		internal function saveSlot(index:int):void
		{
			register[index] = pop();
		}
		
		private function get varDict():Object
		{
			return varDictStack[varDictStack.length-1];
		}
		
		internal function getVar(name:String):void
		{
			push(varDict[name]);
		}
		
		internal function setVar(name:String):void
		{
			varDict[name] = pop();
		}
		
		internal function loadInvokeContext():void
		{
			ip = pop();
			var regCount:int = pop();
			while(regCount-- > 0)
				register[regCount] = pop();
			sc = sp;
			varDictStack.pop();
		}
		
		internal function saveInvokeContext(argCount:int, regCount:int):void
		{
			var argList:Array = [sp-argCount, 0];
			for(var i:int=0; i<regCount; ++i)
				argList.push(register[i]);
			argList.push(regCount, ip);
			valueStack.splice.apply(null, argList);
			sc = sp = sp + regCount + 2;
			varDictStack.push({});
		}
	}
}