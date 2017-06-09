package blockly
{
	public class OpFactory
	{
		static public function JumpIfFalse(offset:int):Array
		{
			return [OpCode.JUMP_IF_FALSE, offset];
		}
		
		static public function Jump(offset:int):Array
		{
			return [OpCode.JUMP, offset];
		}
		
		static public function Push(value:Object):Array
		{
			return [OpCode.PUSH, value];
		}
		
		static public function Call(funcName:String, argCount:int, retCount:int):Array
		{
			return [OpCode.CALL, funcName, argCount, retCount];
		}
		
		static public function Invoke(argCount:int, retCount:int):Array
		{
			return [OpCode.INVOKE, argCount, retCount];
		}
		
		static public function GetVar(name:String):Array
		{
			return [OpCode.GET_VAR, name];
		}
		
		static public function NewFunction(jumpOffset:int, argList:Array, userData:Array):Array
		{
			return [OpCode.NEW_FUNCTION, jumpOffset, argList, userData];
		}
	}
}