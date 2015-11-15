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
			if(thread.pop()){
				thread.ip += count;
			}else{
				++thread.ip;
			}
		}
		
		private function __onInvoke(thread:Thread, address:int):void
		{
			thread.push(thread.ip);
			thread.ip = address;
		}
		
		private function __onReturn(thread:Thread):void
		{
			--thread.sc;
			thread.ip = thread.pop();
		}
	}
}