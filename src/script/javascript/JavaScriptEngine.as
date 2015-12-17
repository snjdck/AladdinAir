package script.javascript
{
	import snjdck.agalc.arithmetic.node.Node;

	public class JavaScriptEngine
	{
		private var arithmetic:JavaScriptArithmetic;
		
		public function JavaScriptEngine()
		{
			arithmetic = new JavaScriptArithmetic();
		}
		
		public function eval(input:String):void
		{
			var node:Node = arithmetic.parse(input);
		}
	}
}