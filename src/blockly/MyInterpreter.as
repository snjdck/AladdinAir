package blockly
{
	public class MyInterpreter extends Interpreter
	{
		public function MyInterpreter()
		{
			regOpHandler(OpCode.CALL, __onCall);
			regOpHandler(OpCode.PUSH, __onPush);
			regOpHandler(OpCode.POP, __onPop);
			regOpHandler(OpCode.JUMP, __onJump);
			regOpHandler(OpCode.JUMP_IF_TRUE, __onJumpIfTrue);
			regOpHandler(OpCode.BREAK, __onDoNothing);
			regOpHandler(OpCode.CONTINUE, __onDoNothing);
			regOpHandler(OpCode.INVOKE, __onInvoke);
			regOpHandler(OpCode.RETURN, __onReturn);
			
			regMethodHandler(BuiltInMethod.NOT, onNot);
			regMethodHandler("+", onAdd);
			regMethodHandler("-", onSub);
			regMethodHandler("*", onMul);
			regMethodHandler("/", onDiv);
		}
		
		private function onAdd(interpreter:Interpreter, argList:Array):void
		{
			interpreter.push(argList[0] + argList[1]);
		}
		
		private function onSub(interpreter:Interpreter, argList:Array):void
		{
			interpreter.push(argList[0] - argList[1]);
		}
		
		private function onMul(interpreter:Interpreter, argList:Array):void
		{
			interpreter.push(argList[0] * argList[1]);
		}
		
		private function onDiv(interpreter:Interpreter, argList:Array):void
		{
			interpreter.push(argList[0] / argList[1]);
		}
		
		private function onNot(interpreter:Interpreter, argList:Array):void
		{
			interpreter.push(!argList[0]);
		}
		
		private function __onDoNothing():void
		{
			++ip;
		}
		
		private function __onCall(methodName:String, argCount:int):void
		{
			var argList:Array = [];
			while(argList.length < argCount){
				argList.push(pop());
			}
			callMethod(methodName, argList.reverse());
			++ip;
		}
		
		private function __onPush(value:Object):void
		{
			push(value);
			++ip;
		}
		
		private function __onPop(count:int):void
		{
			sp -= count;
			++ip;
		}
		
		private function __onJump(count:int):void
		{
			ip += count;
		}
		
		private function __onJumpIfTrue(count:int):void
		{
			if(pop()){
				ip += count;
			}else{
				++ip;
			}
		}
		
		private function __onInvoke(address:int):void
		{
			push(ip);
			ip = address;
		}
		
		private function __onReturn():void
		{
			ip = pop();
		}
	}
}