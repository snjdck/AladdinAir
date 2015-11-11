package blockly.runtime
{
	import blockly.OpCode;

	public class MyInterpreter extends Interpreter
	{
		public function MyInterpreter()
		{
			regOpHandler(OpCode.CALL, __onCall);
			regOpHandler(OpCode.PUSH, __onPush);
			regOpHandler(OpCode.JUMP, __onJump);
			regOpHandler(OpCode.JUMP_IF_TRUE, __onJumpIfTrue);
			regOpHandler(OpCode.BREAK, __onDoNothing);
			regOpHandler(OpCode.CONTINUE, __onDoNothing);
			regOpHandler(OpCode.INVOKE, __onInvoke);
			regOpHandler(OpCode.RETURN, __onReturn);
			
			regMethodHandler("not", onNot);
			regMethodHandler("+", onAdd);
			regMethodHandler("-", onSub);
			regMethodHandler("*", onMul);
			regMethodHandler("/", onDiv);
		}
		
		private function onAdd(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] + argList[1]);
		}
		
		private function onSub(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] - argList[1]);
		}
		
		private function onMul(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] * argList[1]);
		}
		
		private function onDiv(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] / argList[1]);
		}
		
		private function onNot(thread:Thread, argList:Array):void
		{
			thread.push(!argList[0]);
		}
		
		private function __onDoNothing(thread:Thread):void
		{
			++thread.ip;
		}
		
		private function __onCall(thread:Thread, methodName:String, argCount:int):void
		{
			var argList:Array = [];
			while(argList.length < argCount){
				argList.push(thread.pop());
			}
			thread.execMethod(methodName, argList.reverse());
			++thread.ip;
		}
		
		private function __onPush(thread:Thread, value:Object):void
		{
			thread.push(value);
			++thread.ip;
		}
		/*
		private function __onPop(thread:Thread, count:int):void
		{
			thread.sp -= count;
			++thread.ip;
		}
		*/
		private function __onJump(thread:Thread, count:int):void
		{
			thread.ip += count;
		}
		
		private function __onJumpIfTrue(thread:Thread, count:int):void
		{
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
			thread.ip = thread.pop();
		}
	}
}