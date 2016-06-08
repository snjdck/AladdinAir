package blockly.util
{
	import flash.support.Operator;
	
	import blockly.runtime.FunctionProvider;
	import blockly.runtime.Thread;

	public class FunctionProviderHelper
	{
		static public function InitMath(provider:FunctionProvider):void
		{
			provider.register("+", Operator.Add);
			provider.register("-", Operator.Subtract);
			provider.register("*", Operator.Multiply);
			provider.register("/", Operator.Divide);
			provider.register("%", Operator.Modulus);
			
			provider.register("!", Operator.Not);
			provider.register("&&", Operator.And);
			provider.register("||", Operator.Or);
			
			provider.register("<", Operator.LessThan);
			provider.register("<=", Operator.LessEqual);
			provider.register(">", Operator.GreaterThan);
			provider.register(">=", Operator.GreaterEqual);
			provider.register("==", Operator.Equal);
			provider.register("!=", Operator.NotEqual);
			
			provider.register("trace", onTrace);
			provider.register("sleep", onSleep, true);
			provider.register("getProp", onGetProp);
			provider.register("setProp", onSetProp);
		}
		
		static private function onTrace(...argList):void
		{
			trace.apply(null, argList);
		}
		
		static public function onSleep(seconds:Number):void
		{
			Thread.Current.suspendUpdater = [_onSleep, seconds * 1000];
		}
		
		static private function _onSleep(timeout:int):void
		{
			var thread:Thread = Thread.Current;
			if(thread.timeElapsedSinceSuspend >= timeout){
				thread.resume();
			}
		}
		
		static private function onGetProp(target:Object, key:Object):*
		{
			return target[key];
		}
		
		static private function onSetProp(target:Object, key:Object, value:Object):void
		{
			target[key] = value;
		}
	}
}