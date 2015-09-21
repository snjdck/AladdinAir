package blockly
{
	public class Spec
	{
		static private const regExp:RegExp = /%(\w)(?:\.(\w+)|)/g;
		private var spec:String;
		public var nodeList:Array = [];
		
		public function Spec(spec:String)
		{
			this.spec = spec;
			parse();
		}
		
		private function parse():void
		{
			var offset:int = 0;
			for(;;){
				var list:Array = regExp.exec(spec);
				if(null == list){
					break;
				}
				nodeList.push(spec.slice(offset, list.index));
				nodeList.push(list);
				offset = list[0].length + list.index;
			}
			if(offset < spec.length){
				nodeList.push(spec.slice(offset, -1));
			}
			trace(JSON.stringify(nodeList));
		}
	}
}