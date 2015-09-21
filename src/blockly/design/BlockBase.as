package blockly.design
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class BlockBase extends Sprite
	{
		static public const INSERT_PT_BELOW:int = 1;
		static public const INSERT_PT_ABOVE:int = 2;
		static public const INSERT_PT_SUB1:int = 3;
		static public const INSERT_PT_SUB2:int = 4;
		static public const INSERT_PT_WRAP:int = 5;
		static public const INSERT_PT_CHILD:int = 6;
		
		public var isExpression:Boolean;
		private var isSubBlock:Boolean;
		
		private var _nextBlock:BlockBase;
		private var _prevBlock:BlockBase;
		
		private var _parentBlock:BlockBase;
		
		/** 语句参数 */
		public const defaultArgBlockList:Array = [];
		public const argBlockList:Array = [];
		
		/** if,while,for的子句,条件作为argBlock */
		public var subBlock1:MyBlock;
		public var subBlock2:MyBlock;
		
		public var cmd:String;
		
		public function BlockBase()
		{
		}
		
		public function get parentBlock():BlockBase
		{
			return _parentBlock;
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
				return false;
			}else if(isSubBlock){
				return false;
			}
			return null == prevBlock;
		}
		
		public function addBlockToLast(value:BlockBase):void
		{
			lastBlock.nextBlock = value;
		}
		
		public function layoutAfterInsertAbove():void
		{
			var nextBlock:BlockBase = this;
			var block:BlockBase = prevBlock;
			while(block != null){
				block.doLayout(nextBlock.x, nextBlock.y - block.height);
				nextBlock = block;
				block = block.prevBlock;
			}
		}
		
		public function layoutAfterInsertBelow():void
		{
			var prevBlock:BlockBase = this;
			var block:BlockBase = nextBlock;
			while(block != null){
				block.doLayout(prevBlock.x, prevBlock.y + prevBlock.height);
				prevBlock = block;
				block = block.nextBlock;
			}
		}
		
		private function doLayout(px:Number, py:Number):void
		{
			x = px;
			y = py;
			layoutChildren();
		}
		
		public function calcInsertPt():Array
		{
			var result:Array = [];
			result.push(new InsertPtInfo(this, INSERT_PT_ABOVE));
			var block:BlockBase = this;
			while(block != null){
				result.push(new InsertPtInfo(block, INSERT_PT_BELOW));
				block = block.nextBlock;
			}
			return result;
		}
		
		public function getTotalBlockHeight():int
		{
			var result:int = 0;
			var block:BlockBase = this;
			while(block != null){
				result += block.getBlockHeight();
				block = block.nextBlock;
			}
			return result;
		}
		
		public function getBlockWidth():int
		{
			return width;
		}
		
		public function getBlockHeight():int
		{
			return height;
		}
		
		protected function drawBg(w:int, h:int):void
		{
		}
		
		public function setChildBlockAt(block:BlockBase, index:int):void
		{
			if(block == argBlockList[index]){
				return;
			}
			
			var oldBlock:BlockBase = argBlockList[index];
			
			if(oldBlock != null){
				oldBlock._parentBlock = null;
				oldBlock.x += 10;
				oldBlock.y += 10;
			}
			
			argBlockList[index] = block;
			
			if(block != null){
				block._parentBlock = this;
			}
			
			layoutChildren();
		}
		
		private function hasChildBlock(block:BlockBase):Boolean
		{
			return argBlockList.indexOf(block) >= 0;
		}
		
		public function removeFromParentBlock():void
		{
			if(_parentBlock != null){
				_parentBlock.removeChildBlock(this);
			}
		}
		
		public function removeChildBlock(block:BlockBase):void
		{
			var index:int = argBlockList.indexOf(block);
			
			if(index < 0){
				return;
			}
			
			argBlockList[index] = null;
			block._parentBlock = null;
			layoutChildren();
		}
		
		public function layoutChildren():void
		{
			var offsetX:int = 2;
			for(var i:int=0; i<numChildren; i++){
				var obj:DisplayObject = getChildAt(i);
				var index:int = defaultArgBlockList.indexOf(obj);
				if(index >= 0 && argBlockList[index]){
					obj.visible = false;
					var argBlock:BlockBase = argBlockList[index];
					argBlock.doLayout(x + offsetX, y);
					offsetX += argBlock.getBlockWidth();
				}else{
					obj.visible = true;
					obj.x = offsetX;
					offsetX += obj.width;
				}
			}
			graphics.clear();
			drawBg(offsetX, 20);
		}
		
		public function dragBegin():void
		{
			if(isExpression){
				removeFromParentBlock();
			}else{
				prevBlock = null;
			}
		}
		
		public function getTotalCode():String
		{
			var block:BlockBase = this;
			var result:Array = [];
			while(block != null){
				result.push(block.getSelfCode());
				block = block.nextBlock;
			}
			return result.join("\n");
		}
		
		public function getSelfCode():String
		{
			var result:String = cmd;
			var argList:Array = [];
			for(var i:int=0; i<defaultArgBlockList.length; ++i){
				var argBlock:BlockBase = argBlockList[i];
				if(argBlock != null){
					argList[i] = argBlock.getSelfCode();
				}else{
					argList[i] = defaultArgBlockList[i].text;
				}
			}
			return result + "(" + argList.join(", ") + ")";
		}
	}
}