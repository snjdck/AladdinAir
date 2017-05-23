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
		
		public function execute(instruction:Array):void
		{
			var handler:Function = opDict[instruction[0]];
			handler.apply(null, instruction);
		}
		
		private function __onCall(op:Object, methodName:String, argCount:int, retCount:int):void
		{
			var thread:Thread = Thread.Current;
			var argList:Array = getArgList(thread, argCount);
			thread.requestCheckStack(retCount);
			functionProvider.execute(methodName, argList, retCount);
			++thread.ip;
		}
		
		private function __onPush(op:Object, value:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.push(value);
			++thread.ip;
		}
		
		private function __onPop(op:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.pop();
			++thread.ip;
		}
		
		private function __onDuplicate(op:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.push(thread.peek());
			++thread.ip;
		}
		
		private function __onJump(op:Object, count:int):void
		{
			var thread:Thread = Thread.Current;
			thread.ip += count;
			if(count < 0) thread.yield(false);
			else if(count == 0) thread.suspend();
		}
		
		private function __onJumpIfTrue(op:Object, count:int):void
		{
			var thread:Thread = Thread.Current;
			var condition:Boolean = thread.pop();
			thread.ip += condition ? count : 1;
			if(condition && count < 0){
				thread.yield(false);
			}
		}
		
		private function __onInvoke(op:Object, argCount:int, retCount:int):void
		{
			var thread:Thread = Thread.Current;
			var argList:Array = getArgList(thread, argCount);
			var funcRef:FunctionObject = thread.pop();
			thread.pushScope(funcRef.createScope(argList));
			if(funcRef.isRecursiveInvoke()){
				thread.yield(false);
			}
		}
		
		private function __onReturn(op:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.popScope(false);
		}
		
		private function __onNewVar(op:Object, varName:String):void
		{
			var thread:Thread = Thread.Current;
			thread.newVar(varName, thread.pop());
			++thread.ip;
		}
		
		private function __onGetVar(op:Object, varName:String):void
		{
			var thread:Thread = Thread.Current;
			thread.push(thread.getVar(varName));
			++thread.ip;
		}
		
		private function __onSetVar(op:Object, varName:String):void
		{
			var thread:Thread = Thread.Current;
			thread.setVar(varName, thread.pop());
			++thread.ip;
		}
		
		private function __onNewFunction(op:Object, offset:int, argList:Array, userData:Array):void
		{
			var thread:Thread = Thread.Current;
			var addressEnd:int = thread.ip + offset;
			thread.push(thread.newFunction(argList, addressEnd, userData));
			thread.ip = addressEnd;
		}
		
		private function getArgList(thread:Thread, argCount:int):Array
		{
			var argList:Array = [];
			while(argCount-- > 0)
				argList[argCount] = thread.pop();
			return argList;
		}
		
		private function __onDecrease(op:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.put(thread.peek() - 1);
			++thread.ip;
		}
		
		private function __onIsPositive(op:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.put(thread.peek() > 0);
			++thread.ip;
		}
		
		private function __onYield(op:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.popScope(true);
		}
		
		private function __onYieldFrom(op:Object):void
		{
			var thread:Thread = Thread.Current;
			var subScope:FunctionScope = thread.pop();
			var scope:FunctionScope = thread.pop();
			
			subScope.prevScope = scope;
			scope.nextScope = subScope;
			
			thread.push(subScope);
			
			subScope.prevContext = scope.prevContext;
			subScope.returnAddress = scope.returnAddress;
			
			thread.context = subScope.nextContext;
			thread.ip = subScope.defineAddress + 1;
		}
		
		private function __onCoroutineNew(op:Object, argCount:int):void
		{
			var thread:Thread = Thread.Current;
			var argList:Array = getArgList(thread, argCount);
			var funcRef:FunctionObject = thread.pop();
			thread.push(funcRef.createScope(argList));
			++thread.ip;
		}
		
		private function __onCoroutineResume(op:Object):void
		{
			var thread:Thread = Thread.Current;
			var scope:FunctionScope = thread.pop();
			if(scope.isExecuting(thread)){
				thread.interrupt();
			}else if(scope.isFinish()){
				++thread.ip;
			}else{
				thread.pushScope(scope.getFinalScope());
			}
		}
	}
}