package blockly.runtime
{
	import blockly.OpCode;

	internal class InstructionExector
	{
		internal var profiler:CodeProfiler;
		
		private var functionProvider:FunctionProvider;
		
		private const opDict:Object = {};
		private const argList:Array = [];
		
		private var nextOp:Object;
		private var nextData:Array;
		
		public function InstructionExector(functionProvider:FunctionProvider)
		{
			regOpHandler(OpCode.CALL, __onCall);
			regOpHandler(OpCode.PUSH, __onPush);
			regOpHandler(OpCode.JUMP, __onJump);
			regOpHandler(OpCode.JUMP_IF_FALSE, __onJumpIfFalse);
			regOpHandler(OpCode.INVOKE, __onInvoke);
			regOpHandler(OpCode.RETURN, __onReturn);
			regOpHandler(OpCode.JUMP_IF_NOT_POSITIVE, __onJumpIfNotPositive);
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
		
		public function optimize(codeList:Array):void
		{
			for each(var code:Array in codeList){
				code[0] = opDict[code[0]];
			}
		}
		
		public function execute(instruction:Array, nextInstruction:Array):void
		{
			nextOp = nextInstruction && nextInstruction[0];
			nextData = nextInstruction;
			var handler:Function = instruction[0];
			handler.apply(null, instruction);
		}
		
		private function __onCall(op:Object, method:String, argCount:int, retCount:int, params:Array=null):void
		{
			var thread:Thread = Thread.Current;
			getArgList(thread, argCount);
			if(profiler != null){
				profiler.begin(method);
			}
			functionProvider.execute(thread, method, getParamList(params), retCount);
			if(profiler != null){
				profiler.end(method);
			}
			++thread.ip;
		}
		
		private function __onPush(op:Object, value:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.push(value);
			++thread.ip;
		}
		
		private function __onJump(op:Object, count:int):void
		{
			var thread:Thread = Thread.Current;
			thread.ip += count;
			if(count < 0) thread.yield(false);
			else if(count == 0) thread.suspend();
		}
		
		private function __onJumpIfFalse(op:Object, count:int):void
		{
			var thread:Thread = Thread.Current;
			if(thread.pop()){
				count = (nextOp == __onJump) ? (nextData[1] + 1) : 1;
			}
			if(count < 0){
				thread.yield(false);
			}
			thread.ip += count;
		}
		
		private function __onJumpIfNotPositive(op:Object, count:int):void
		{
			var thread:Thread = Thread.Current;
			var value:int = thread.peek();
			if(value <= 0){
				thread.pop();
				thread.ip += count;
			}else{
				thread.put(value - 1);
				++thread.ip;
			}
		}
		
		private function __onInvoke(op:Object, argCount:int, retCount:int, params:Array=null):void
		{
			var thread:Thread = Thread.Current;
			getArgList(thread, argCount);
			var funcRef:FunctionObject = thread.pop();
			var scope:FunctionScope = funcRef.createScope(getParamList(params));
			scope.doInvoke(thread);
			if(thread.isRecursiveInvoke(funcRef)){
				thread.yield(false);
			}
			if(retCount == 0 && nextOp == __onReturn){
				thread.overrideScope(scope);
			}else{
				thread.pushScope(scope);
			}
		}
		
		private function __onReturn(op:Object):void
		{
			var thread:Thread = Thread.Current;
			var scope:FunctionScope = thread.popScope();
			scope.defineAddress = scope.finishAddress;
			scope.doReturn(thread);
			if(scope.prevScope != null){
				scope.prevScope.nextScope = null;
				scope.prevScope = null;
			}
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
		
		private function getArgList(thread:Thread, argCount:int):void
		{
			argList.length = argCount;
			while(argCount-- > 0)
				argList[argCount] = thread.pop();
		}
		
		private function getParamList(info:Array):Array
		{
			if(info == null){
				return argList;
			}
			var paramList:Array = info[0];
			var indexList:Array = info[1];
			for(var i:int=indexList.length-1; i>=0; --i){
				paramList[indexList[i]] = argList[i];
			}
			return paramList;
		}
		
		private function __onYield(op:Object):void
		{
			var thread:Thread = Thread.Current;
			var scope:FunctionScope = thread.popScope();
			scope.defineAddress = thread.ip;
			scope.doReturn(thread);
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
			getArgList(thread, argCount);
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
				scope = scope.getFinalScope();
				scope.doInvoke(thread);
				thread.pushScope(scope);
			}
		}
	}
}