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
		
		public function execute(codeList:Array):void
		{
			this.codeList = codeList;
			ip = 0;
			isSuspend = false;
			execNextCode();
		}
		
		public function execNextCode():void
		{
			if(isSuspend || ip >= codeList.length){
				return;
			}
			var code:Array = codeList[ip];
			var opHandler:Function = opDict[code[0]];
			opHandler.apply(null, code.slice(1));
		}
		
		public function suspend():void
		{
			isSuspend = true;
		}
		
		public function restore():void
		{
			isSuspend = false;
		}
		
		public function push(value:Object):void
		{
			stack[sp++] = value;
		}
		
		public function pop():*
		{
			return stack[sp--];
		}
		
		public function callMethod(methodName:String, argList:Array):void
		{
			var handler:Function = methodDict[methodName];
			handler(this, argList);
		}
	}
}