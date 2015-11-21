package blockly.runtime
{
	import blockly.OpCode;

	internal class InstructionExector
	{
		private var functionProvider:FunctionProvider;
		private const opDict:Object = {};
		
		public function InstructionExector(functionProvider:FunctionProvider)
		{
			regOpHandler(OpCode.CALL, __onCall);
			regOpHandler(OpCode.PUSH, __onPush);
			regOpHandler(OpCode.JUMP, __onJump);
			regOpHandler(OpCode.JUMP_IF_TRUE, __onJumpIfTrue);
			regOpHandler(OpCode.INVOKE, __onInvoke);
			regOpHandler(OpCode.RETURN, __onReturn);
			regOpHandler(OpCode.LOAD_SLOT, __onLoadSlot);
			regOpHandler(OpCode.SAVE_SLOT, __onSaveSlot);
			
			this.functionProvider = functionProvider;
		}
		
		public function regOpHandler(op:String, handler:Function):void
		{
			opDict[op] = handler;
		}
		
		public function execute(thread:Thread, op:String, argList:Array):void
		{
			var handler:Function = opDict[op];
			assert(handler != null);
			argList.unshift(thread);
			handler.apply(null, argList);
		}
		
		private function __onCall(thread:Thread, methodName:String, argCount:int, retCount:int):void
		{
			var argList:Array = [];
			while(argList.length < argCount){
				argList.push(thread.pop());
			}
			functionProvider.execute(thread, methodName, argList.reverse());
			thread.sc += retCount - argCount;
			++thread.ip;
		}
		
		private function __onPush(thread:Thread, value:Object):void
		{
			thread.push(value);
			++thread.sc;
			++thread.ip;
		}
		
		private function __onJump(thread:Thread, count:int):void
		{
			thread.ip += count;
		}
		
		private function __onJumpIfTrue(thread:Thread, count:int):void
		{
			--thread.sc;
			thread.ip += thread.pop() ? count : 1;
		}
		
		private function __onLoadSlot(thread:Thread, index:int):void
		{
			__onPush(thread, thread.getSlot(index));
		}
		
		private function __onSaveSlot(thread:Thread, index:int):void
		{
			thread.setSlot(index, thread.pop());
			--thread.sc;
			++thread.ip;
		}
		
		private function __onInvoke(thread:Thread, jumpCount:int, argCount:int, retCount:int, regCount:int):void
		{
			var i:int;
			if(argCount > 0)
			for(i=argCount+regCount-1; i>=argCount; --i)
				thread.setSlot(i, thread.getSlot(i-argCount));
			for(i=argCount-1; i>=0; --i)
				thread.setSlot(i, thread.pop());
			thread.push(thread.ip);
			for(i=0; i<regCount; ++i)
				thread.push(thread.getSlot(argCount+i));
			thread.push(regCount);
			thread.sc += regCount + 2 - argCount;
			thread.ip += jumpCount;
		}
		
		private function __onReturn(thread:Thread):void
		{
			var regCount:int = thread.pop();
			thread.sc -= regCount + 2;
			while(regCount-- > 0)
				thread.setSlot(regCount, thread.pop());
			thread.ip = thread.pop() + 1;
		}
	}
}