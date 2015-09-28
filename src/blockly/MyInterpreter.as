package blockly
{
	public class MyInterpreter extends Interpreter
	{
		public function MyInterpreter()
		{
			regOpHandler(OpCode.CALL, __onCall);
			regOpHandler(OpCode.PUSH, __onPush);
			regOpHandler(OpCode.JUMP, __onJump);
//			regOpHandler(OpCode.JUMP_IF_FALSE, __onJumpIfFalse);
			regOpHandler(OpCode.JUMP_IF_TRUE, __onJumpIfTrue);
			regOpHandler(OpCode.BREAK, __onDoNothing);
			regOpHandler(OpCode.CONTINUE, __onDoNothing);
			regOpHandler(OpCode.INVOKE, __onInvoke);
			regOpHandler(OpCode.RETURN, __onReturn);
			
			regMethodHandler(BuiltInMethod.NOT, onNot);
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
			while(argCount > 0){
				argList.unshift(pop());
			}
			callMethod(methodName, argList);
			++ip;
		}
		
		private function __onPush(value:Object):void
		{
			push(value);
			++ip;
		}
		
		private function __onJump(offset:int):void
		{
			ip += offset;
		}
		
		private function __onJumpIfTrue(offset:int):void
		{
			if(pop()){
				ip += offset;
			}
		}
		/*
		private function __onJumpIfFalse(offset:int):void
		{
			if(!pop()){
				ip += offset;
			}
		}
		*/
		
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