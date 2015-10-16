package blockly
{
	import dict.getValues;

	public class BoardDefine
	{
		private var portDict:Object;
		
		public function BoardDefine()
		{
			portDict = {};
		}
		
		public function addPortDefine(id:int, name:String, flag:uint):void
		{
			var portDefine:PortDefine = new PortDefine();
			portDefine.id = id;
			portDefine.name = name;
			portDefine.flag = flag;
			portDict[name] = portDefine;
		}
		
		public function getAllPorts():Array
		{
			return getValues(portDict);
		}
		
		public function getPorts(flag:uint):Array
		{
			var result:Array = [];
			for each(var portDefine:PortDefine in portDict){
				if((portDefine.flag & flag) > 0){
					result.push(portDefine);
				}
			}
			result.sortOn("name");
			return result;
		}
	}
}