package blockly
{
	public class MyInterpreter extends Interpreter
	{
		public function MyInterpreter()
		{
			regOpHandler(OpCode.CALL, __onCall);
			regOpHandler(OpCode.PUSH, __onPush);
			regOpHandler(OpCode.JUMP, __onJump);
			regOpHandler(OpCode.JUMP_IF_FALSE, __onJumpIfFalse);
			regOpHandler(OpCode.JUMP_IF_TRUE, __onJumpIfTrue);
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
		
		private function __onJumpIfFalse(offset:int):void
		{
			if(!pop()){
				ip += offset;
			}
		}
	}
}