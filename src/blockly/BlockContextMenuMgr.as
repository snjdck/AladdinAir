package blockly
{
	import blockly.design.BlockArg;

	public class BlockContextMenuMgr
	{
		static public const Instance:BlockContextMenuMgr = new BlockContextMenuMgr();
		
		public var boardDefine:BoardDefine;
		
		public function BlockContextMenuMgr()
		{
			boardDefine = BoardDefineFactory.GetMBot();
		}
		
		public function show(blockArg:BlockArg, menuName:String):void
		{
//			if(info[2] == "port"){
				trace(boardDefine.getPorts(blockArg.block.flag));
//			}
		}
	}
}