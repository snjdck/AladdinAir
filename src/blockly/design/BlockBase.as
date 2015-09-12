package blockly.design
{
	import flash.display.Sprite;

	public class BlockBase extends Sprite
	{
		static public const INSERT_PT_BELOW:int = 1;
		static public const INSERT_PT_ABOVE:int = 2;
		static public const INSERT_PT_SUB1:int = 3;
		static public const INSERT_PT_SUB2:int = 4;
		static public const INSERT_PT_WRAP:int = 5;
		
		public var isExpression:Boolean;
		private var isSubBlock:Boolean;
		
		private var _nextBlock:BlockBase;
		private var _prevBlock:BlockBase;
		
		public function BlockBase()
		{
		}
		
		public function get prevBlock():BlockBase
		{
			return _prevBlock;
		}
		
		public function get nextBlock():BlockBase
		{
			return _nextBlock;
		}
		
		public function set prevBlock(value:BlockBase):void
		{
			if(value == _prevBlock){
				return;
			}
			if(_prevBlock != null){
				_prevBlock._nextBlock = null;
			}
			_prevBlock = value;
			if(_prevBlock != null){
				_prevBlock.nextBlock = this;
			}
		}
		
		public function set nextBlock(value:BlockBase):void
		{
			if(value == _nextBlock){
				return;
			}
			if(_nextBlock != null){
				_nextBlock._prevBlock = null;
			}
			_nextBlock = value;
			if(_nextBlock != null){
				_nextBlock.prevBlock = this;
			}
		}
		
		public function get topBlock():BlockBase
		{
			var block:BlockBase = this;
			while(block.prevBlock != null){
				block = block.prevBlock;
			}
			return block;
		}
		
		public function get lastBlock():BlockBase
		{
			var block:BlockBase = this;
			while(block.nextBlock != null){
				block = block.nextBlock;
			}
			return block;
		}
		
		public function isTopBlock():Boolean
		{
			if(isExpression){
				
			}else if(isSubBlock){
				return false;
			}
			return null == prevBlock;
		}
		
		public function addBlockToLast(value:BlockBase):void
		{
			lastBlock.nextBlock = value;
		}
		
		public function relayout():void
		{
			var prevBlock:BlockBase = this;
			var block:BlockBase = nextBlock;
			while(block != null){
				block.x = prevBlock.x;
				block.y = prevBlock.y + prevBlock.height;
				
				prevBlock = block;
				block = block.nextBlock;
			}
		}
		
		public function calcInsertPt():Array
		{
			var result:Array = [];
			result.push([this, INSERT_PT_ABOVE]);
			var block:BlockBase = this;
			while(block != null){
				result.push([block, INSERT_PT_BELOW]);
				block = block.nextBlock;
			}
			return result;
		}
	}
}