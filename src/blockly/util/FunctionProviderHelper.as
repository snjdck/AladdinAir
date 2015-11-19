package blockly.util
{
	import blockly.runtime.FunctionProvider;
	import blockly.runtime.Thread;

	public class FunctionProviderHelper
	{
		static public function InitMath(provider:FunctionProvider):void
		{
			provider.registerNative("+", onAdd);
			provider.registerNative("-", onSub);
			provider.registerNative("*", onMul);
			provider.registerNative("/", onDiv);
			provider.registerNative("%", onMod);
			
			provider.registerNative("!", onNot);
			provider.registerNative("&&", onAnd);
			provider.registerNative("||", onOr);
			
			provider.registerNative("<", onLess);
			provider.registerNative("<=", onLessEqual);
			provider.registerNative(">", onGreater);
			provider.registerNative(">=", onGreaterEqual);
			provider.registerNative("==", onEqual);
			provider.registerNative("!=", onNotEqual);
		}
		
		static private function onAdd(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] + argList[1]);
		}
		
		static private function onSub(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] - argList[1]);
		}
		
		static private function onMul(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] * argList[1]);
		}
		
		static private function onDiv(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] / argList[1]);
		}
		
		static private function onMod(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] % argList[1]);
		}
		
		static private function onNot(thread:Thread, argList:Array):void
		{
			thread.push(!argList[0]);
		}
		
		static private function onAnd(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] && argList[1]);
		}
		
		static private function onOr(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] || argList[1]);
		}
		
		static private function onLess(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] < argList[1]);
		}
		
		static private function onLessEqual(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] <= argList[1]);
		}
		
		static private function onGreater(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] > argList[1]);
		}
		
		static private function onGreaterEqual(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] >= argList[1]);
		}
		
		static private function onEqual(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] == argList[1]);
		}
		
		static private function onNotEqual(thread:Thread, argList:Array):void
		{
			thread.push(argList[0] != argList[1]);
		}
	}
}