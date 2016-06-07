package blockly.util
{
	import blockly.runtime.FunctionProvider;
	import blockly.runtime.Thread;

	public class FunctionProviderHelper
	{
		static public function InitMath(provider:FunctionProvider):void
		{
			provider.register("+", onAdd);
			provider.register("-", onSub);
			provider.register("*", onMul);
			provider.register("/", onDiv);
			provider.register("%", onMod);
			
			provider.register("!", onNot);
			provider.register("&&", onAnd);
			provider.register("||", onOr);
			
			provider.register("<", onLess);
			provider.register("<=", onLessEqual);
			provider.register(">", onGreater);
			provider.register(">=", onGreaterEqual);
			provider.register("==", onEqual);
			provider.register("!=", onNotEqual);
			
			provider.register("trace", onTrace);
			provider.register("sleep", onSleep);
			provider.register("getProp", onGetProp);
			provider.register("setProp", onSetProp);
		}
		
		static private function onTrace(...argList):void
		{
			trace.apply(null, argList);
		}
		
		static public function onSleep(seconds:Number):void
		{
			var thread:Thread = Thread.Current;
			thread.suspend();
			thread.suspendUpdater = [_onSleep, seconds * 1000];
		}
		
		static private function _onSleep(timeout:int):void
		{
			var thread:Thread = Thread.Current;
			if(thread.timeElapsedSinceSuspend >= timeout){
				thread.resume();
			}
		}
		
		static private function onGetProp(target:Object, key:Object):void
		{
			var thread:Thread = Thread.Current;
			thread.push(target[key]);
		}
		
		static private function onSetProp(target:Object, key:Object, value:Object):void
		{
			target[key] = value;
		}
		
		static private function onAdd(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a + b);
		}
		
		static private function onSub(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a - b);
		}
		
		static private function onMul(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a * b);
		}
		
		static private function onDiv(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a / b);
		}
		
		static private function onMod(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a % b);
		}
		
		static private function onNot(value:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(!value);
		}
		
		static private function onAnd(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a && b);
		}
		
		static private function onOr(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a || b);
		}
		
		static private function onLess(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a < b);
		}
		
		static private function onLessEqual(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a <= b);
		}
		
		static private function onGreater(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a > b);
		}
		
		static private function onGreaterEqual(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a >= b);
		}
		
		static private function onEqual(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a == b);
		}
		
		static private function onNotEqual(a:*, b:*):void
		{
			var thread:Thread = Thread.Current;
			thread.push(a != b);
		}
	}
}