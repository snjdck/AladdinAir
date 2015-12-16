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
			regOpHandler(OpCode.NEW_VAR, __onNewVar);
			regOpHandler(OpCode.GET_VAR, __onGetVar);
			regOpHandler(OpCode.SET_VAR, __onSetVar);
			regOpHandler(OpCode.NEW_FUNCTION, __onNewFunction);
			
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
			var argList:Array = getArgList(thread, argCount);
			thread.requestCheckStack(retCount);
			functionProvider.execute(thread, methodName, argList);
			++thread.ip;
		}
		
		private function __onPush(thread:Thread, value:Object):void
		{
			thread.push(value);
			++thread.ip;
		}
		
		private function __onJump(thread:Thread, count:int):void
		{
			thread.ip += count;
		}
		
		private function __onJumpIfTrue(thread:Thread, count:int):void
		{
			thread.ip += thread.pop() ? count : 1;
		}
		
		private function __onLoadSlot(thread:Thread, index:int):void
		{
			__onPush(thread, thread.getSlot(index));
		}
		
		private function __onSaveSlot(thread:Thread, index:int):void
		{
			thread.setSlot(index, thread.pop());
			++thread.ip;
		}
		
		private function __onInvoke(thread:Thread, argCount:int, retCount:int, regCount:int):void
		{
			var argList:Array = getArgList(thread, argCount);
			thread.increaseRegOffset(regCount);
			var funcRef:* = thread.pop();
			if(funcRef is FunctionObject){
				var funcObj:FunctionObject = funcRef;
				thread.push(thread.ip);
				thread.push(-regCount);
				funcObj.invoke(thread, argList);
			}else if(funcRef is Function){
				funcRef(thread, argList);
				++thread.ip;
			}else{
				assert(false);
				thread.interrupt();
			}
		}
		
		private function __onReturn(thread:Thread):void
		{
			thread.popScope();
			thread.increaseRegOffset(thread.pop());
			thread.ip = thread.pop() + 1;
		}
		
		private function __onNewVar(thread:Thread, varName:String):void
		{
			thread.newVar(varName, thread.pop());
			++thread.ip;
		}
		
		private function __onGetVar(thread:Thread, varName:String):void
		{
			var value:Object;
			if(thread.hasVar(varName)){
				value = thread.getVar(varName);
			}else if(functionProvider.hasVar(varName)){
				value = functionProvider.getVar(varName);
			}
			__onPush(thread, value);
		}
		
		private function __onSetVar(thread:Thread, varName:String):void
		{
			thread.setVar(varName, thread.pop());
			++thread.ip;
		}
		
		private function __onNewFunction(thread:Thread, offset:int, argList:Array):void
		{
			thread.push(new FunctionObject(thread.getContext(), argList, thread.ip + 1));
			thread.ip += offset;
		}
		
		private function getArgList(thread:Thread, argCount:int):Array
		{
			var argList:Array = [];
			while(argCount-- > 0)
				argList[argCount] = thread.pop();
			return argList;
		}
	}
}