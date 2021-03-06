package blockly
{
	final public class OpCode
	{
		static public const JUMP:String = "jump";
//		static public const JUMP_IF_TRUE:String = "jumpIfTrue";
		static public const JUMP_IF_FALSE:String = "jumpIfFalse";
		static public const CALL:String = "call";
		static public const PUSH:String = "push";
		
		static public const BREAK:String = "break";
		static public const CONTINUE:String = "continue";
		
//		static public const DUPLICATE:String = "duplicate";
//		static public const POP:String = "pop";
		
		static public const RETURN:String = "return";
		static public const INVOKE:String = "invoke";
		
		static public const NEW_VAR:String = "newVar";
		static public const GET_VAR:String = "getVar";
		static public const SET_VAR:String = "setVar";
		
		static public const NEW_FUNCTION:String = "newFunction";
		
//		static public const DECREASE:String = "decrease";
		static public const IS_POSITIVE:String = "isPositive";
		static public const JUMP_IF_NOT_POSITIVE:String = "jumpIfNotPositive";
		
		static public const YIELD:String = "yield";
		static public const YIELD_FROM:String = "yieldFrom";
		static public const COROUTINE_NEW:String = "coroutineNew";
		static public const COROUTINE_RESUME:String = "coroutineResume";
	}
}