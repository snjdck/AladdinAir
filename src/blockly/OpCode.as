package blockly
{
	/**
	 * call function =>
	 * pushScope
	 * push:arg1
	 * setVar:a
	 * push:arg2
	 * setVar:b
	 * ...
	 * invoke:address
	 * popScope
	 */	
	final public class OpCode
	{
		static public const JUMP:String = "jump";
		static public const JUMP_IF_TRUE:String = "jumpIfTrue";
		static public const CALL:String = "call";
		static public const PUSH:String = "push";
		static public const POP:String = "pop";
		static public const BREAK:String = "break";
		static public const CONTINUE:String = "continue";
		
		//set current ip from stack
		static public const RETURN:String = "return";
		//push current ip to stack
		static public const INVOKE:String = "invoke";
		
		static public const PUSH_SCOPE:String = "pushScope";
		static public const POP_SCOPE:String = "popScope";
		
		static public const GET_VAR:String = "getVar";
		static public const SET_VAR:String = "setVar";
	}
}