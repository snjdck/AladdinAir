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
			regOpHandler(OpCode.DUPLICATE, __onDuplicate);
			regOpHandler(OpCode.POP, __onPop);
			regOpHandler(OpCode.NEW_VAR, __onNewVar);
			regOpHandler(OpCode.GET_VAR, __onGetVar);
			regOpHandler(OpCode.SET_VAR, __onSetVar);
			regOpHandler(OpCode.NEW_FUNCTION, __onNewFunction);
			
			regOpHandler(OpCode.DECREASE, __onDecrease);
			regOpHandler(OpCode.IS_POSITIVE, __onIsPositive);
			
			this.functionProvider = functionProvider;
		}
		
		public function regOpHandler(op:String, handler:Function):void
		{
			opDict[op] = handler;
		}
		
		public function execute(thread:Thread, op:String, argList:Array):Boolean
		{
			var handler:Function = opDict[op];
			assert(handler != null);
			argList.unshift(thread);
			return handler.apply(null, argList);
		}
		
		private function __onCall(thread:Thread, methodName:String, argCount:int, retCount:int):void
		{
			var argList:Array = getArgList(thread, argCount);
			thread.requestCheckStack(retCount);
			functionProvider.execute(thread, methodName, argList, retCount);
			++thread.ip;
		}
		
		private function __onPush(thread:Thread, value:Object):void
		{
			thread.push(value);
			++thread.ip;
		}
		
		private function __onPop(thread:Thread):void
		{
			thread.pop();
			++thread.ip;
		}
		
		private function __onDuplicate(thread:Thread):void
		{
			var value:Object = thread.pop();
			thread.push(value);
			thread.push(value);
			++thread.ip;
		}
		
		private function __onJump(thread:Thread, count:int):*
		{
			thread.ip += count;
			if(count <  0) return true;
			if(count == 0) thread.suspend();
		}
		
		private function __onJumpIfTrue(thread:Thread, count:int):*
		{
			var condition:Boolean = thread.pop();
			thread.ip += condition ? count : 1;
			if(condition && count < 0)
				return true;
		}
		
		private function __onInvoke(thread:Thread, argCount:int, retCount:int):Boolean
		{
			var argList:Array = getArgList(thread, argCount);
			var funcRef:FunctionObject = thread.pop();
			thread.pushScope(funcRef.createScope(argList));
			return funcRef.isRecursiveInvoke();
		}
		
		private function __onReturn(thread:Thread):void
		{
			thread.popScope(false);
		}
		
		private function __onNewVar(thread:Thread, varName:String):void
		{
			thread.newVar(varName, thread.pop());
			++thread.ip;
		}
		
		private function __onGetVar(thread:Thread, varName:String):void
		{
			thread.push(thread.getVar(varName));
			++thread.ip;
		}
		
		private function __onSetVar(thread:Thread, varName:String):void
		{
			thread.setVar(varName, thread.pop());
			++thread.ip;
		}
		
		private function __onNewFunction(thread:Thread, offset:int, argList:Array):void
		{
			var addressEnd:int = thread.ip + offset;
			thread.push(new FunctionObject(thread.context, argList, thread.ip, addressEnd));
			thread.ip = addressEnd;
		}
		
		private function getArgList(thread:Thread, argCount:int):Array
		{
			var argList:Array = [];
			while(argCount-- > 0)
				argList[argCount] = thread.pop();
			return argList;
		}
		
		private function __onDecrease(thread:Thread):void
		{
			thread.push(thread.pop() - 1);
			++thread.ip;
		}
		
		private function __onIsPositive(thread:Thread):void
		{
			thread.push(thread.pop() > 0);
			++thread.ip;
		}
		
		private function __onYield(thread:Thread):void
		{
			thread.popScope(true);
		}
		
		private function __onCoroutineNew(thread:Thread, argCount:int):void
		{
			var argList:Array = getArgList(thread, argCount);
			var funcRef:FunctionObject = thread.pop();
			thread.push(funcRef.createScope(argList));
			++thread.ip;
		}
		
		private function __onCoroutineResume(thread:Thread):void
		{
			var scope:FunctionScope = thread.pop();
			if(scope.isExecuting(thread)){
				thread.interrupt();
			}else if(scope.isFinish()){
				++thread.ip;
			}else{
				thread.pushScope(scope);
			}
		}
	}
}