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
			regOpHandler(OpCode.POP, __onPop);
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
		
		private function __onPop(thread:Thread, count:int):void
		{
			thread.sc -= count;
			while(count-- > 0)
				thread.pop();
			++thread.ip;
		}
		
		private function __onJump(thread:Thread, count:int):void
		{
			thread.ip += count;
		}
		
		private function __onJumpIfTrue(thread:Thread, count:int):void
		{
			--thread.sc;
			if(thread.pop()){
				thread.ip += count;
			}else{
				++thread.ip;
			}
		}
		
		private function __onInvoke(thread:Thread, jumpCount:int, argCount:int, retCount:int, regCount:int):void
		{
			thread.saveInvokeContext(argCount, regCount);
			thread.ip += jumpCount;
		}
		
		private function __onReturn(thread:Thread):void
		{
			thread.loadInvokeContext();
			++thread.ip;
		}
		
		private function __onLoadSlot(thread:Thread, index:int):void
		{
			thread.loadSlot(index);
			++thread.sc;
			++thread.ip;
		}
		
		private function __onSaveSlot(thread:Thread, index:int):void
		{
			thread.saveSlot(index);
			--thread.sc;
			++thread.ip;
		}
	}
}