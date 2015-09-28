package blockly
{
	public class OpFactory
	{
		static public function JumpIfTrue(offset:int):Array
		{
			return [OpCode.JUMP_IF_TRUE, offset];
		}
		
		static public function Jump(offset:int):Array
		{
			return [OpCode.JUMP, offset];
		}
		
		static public function Push(value:Object):Array
		{
			return [OpCode.PUSH, value];
		}
		
		static public function Pop(count:int):Array
		{
			return [OpCode.POP, count];
		}
		
		static public function Call(funcName:String, argCount:int):Array
		{
			return [OpCode.CALL, funcName, argCount];
		}
	}
}