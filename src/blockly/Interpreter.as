package blockly
{
	public class Interpreter
	{
		protected var opDict:Object = {};
		protected var methodDict:Object = {};
		protected var ip:int = 0;
		protected var stack:Array = [];
		protected var sp:int = 0;
		
		private var codeList:Array;
		private var isSuspend:Boolean;
		
		public function Interpreter()
		{
		}
		
		public function regOpHandler(op:String, handler:Function):void
		{
			opDict[op] = handler;
		}
		
		public function regMethodHandler(methodName:String, handler:Function):void
		{
			methodDict[methodName] = handler;
		}
		
		public function isFinish():Boolean
		{
			return ip >= codeList.length;
		}
		
		public function execute(codeList:Array):void
		{
			this.codeList = codeList;
			ip = 0;
			sp = 0;
			resume();
		}
		
		private function execNextCode():void
		{
			var code:Array = codeList[ip];
			var opHandler:Function = opDict[code[0]];
			opHandler.apply(null, code.slice(1));
		}
		
		public function suspend():void
		{
			isSuspend = true;
		}
		
		public function resume():void
		{
			isSuspend = false;
			while(!(isSuspend || isFinish())){
				execNextCode();
			}
		}
		
		public function push(value:Object):void
		{
			stack[sp++] = value;
		}
		
		public function pop():*
		{
			return stack[--sp];
		}
		
		public function callMethod(methodName:String, argList:Array):void
		{
			var handler:Function = methodDict[methodName];
			if(null == handler){
				trace("interpreter invoke method:", methodName, argList);
			}else{
				handler(this, argList);
			}
		}
	}
}