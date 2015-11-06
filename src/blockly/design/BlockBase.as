package blockly.design
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;

	public class BlockBase extends Sprite
	{
		static public const BLOCK_TYPE_EXPRESSION:int = 1;
		static public const BLOCK_TYPE_STATEMENT:int = 2;
		static public const BLOCK_TYPE_FOR:int = 3;
		static public const BLOCK_TYPE_IF:int = 4;
		static public const BLOCK_TYPE_BREAK:int = 5;
		static public const BLOCK_TYPE_CONTINUE:int = 6;
		
		static public const INSERT_PT_BELOW:int = 1;
		static public const INSERT_PT_ABOVE:int = 2;
		static public const INSERT_PT_SUB1:int = 3;
		static public const INSERT_PT_SUB2:int = 4;
		static public const INSERT_PT_WRAP:int = 5;
		static public const INSERT_PT_CHILD:int = 6;
		
		public var type:int;
		public var flag:uint;
		
		private var _nextBlock:BlockBase;
		private var _prevBlock:BlockBase;
		
		private var _parentBlock:BlockBase;
		
		/** 语句参数 */
		public const defaultArgBlockList:Array = [];
		public const argBlockList:Array = [];
		
		private var _subBlock1:BlockBase;
		private var _subBlock2:BlockBase;
		
		public var cmd:String;
		private var _totalWidth:int;
		
		public function BlockBase()
		{
		}
		
		public function get subBlock1():BlockBase
		{
			return _subBlock1;
		}

		public function set subBlock1(value:BlockBase):void
		{
			if(value == _subBlock1){
				return;
			}
			if(_subBlock1 != null){
				_subBlock1._parentBlock = null;
			}
			_subBlock1 = value;
			if(_subBlock1 != null){
				_subBlock1._parentBlock = this;
			}
		}
		
		public function get subBlock2():BlockBase
		{
			return _subBlock2;
		}

		public function set subBlock2(value:BlockBase):void
		{
			if(value == _subBlock2){
				return;
			}
			if(_subBlock2 != null){
				_subBlock2._parentBlock = null;
			}
			_subBlock2 = value;
			if(_subBlock2 != null){
				_subBlock2._parentBlock = this;
			}
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
		
		public function hasSubBlock2():Boolean
		{
			return type == BLOCK_TYPE_IF;
		}
		
		public function isExpression():Boolean
		{
			return type == BLOCK_TYPE_EXPRESSION;
		}
		
		public function isSubBlock():Boolean
		{
			if(null == _parentBlock){
				return false;
			}
			switch(this){
				case _parentBlock._subBlock1:
				case _parentBlock._subBlock2:
					return true;
			}
			return false;
		}
		
		public function isControlBlock():Boolean
		{
			switch(type){
				case BLOCK_TYPE_FOR:
				case BLOCK_TYPE_IF:
					return true;
			}
			return false;
		}
		
		public function isTopBlock():Boolean
		{
			if(isExpression() || isSubBlock()){
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
			relayout();
		}
		
		public function relayout():void
		{
			layoutSubBlock();
			layoutChildren();
		}
		
		public function calcInsertPt():Array
		{
			var result:Array = [];
			collectInsertPt(this, result);
			return result;
		}
		
		private function collectInsertPt(block:BlockBase, result:Array):void
		{
			while(block != null){
				switch(block.type){
					case BLOCK_TYPE_IF:
						result.push(new InsertPtInfo(block, INSERT_PT_SUB2));
						collectInsertPt(block.subBlock2, result);
					case BLOCK_TYPE_FOR:
						result.push(new InsertPtInfo(block, INSERT_PT_SUB1));
						collectInsertPt(block.subBlock1, result);
					case BLOCK_TYPE_STATEMENT:
						result.push(new InsertPtInfo(block, INSERT_PT_BELOW));
				}
				block = block.nextBlock;
			}
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
		
		public function getPositionSub1():Number
		{
			return 20;
		}
		
		public function getPositionSub2():Number
		{
			return 30 + getSub1Height();
		}
		
		private function getSub1Height():int
		{
			return _subBlock1 != null ? _subBlock1.getTotalBlockHeight() : 10;
		}
		
		private function getSub2Height():int
		{
			return _subBlock2 != null ? _subBlock2.getTotalBlockHeight() : 10;
		}
		
		public function drawBg():void
		{
			var w:int = _totalWidth;
			var h:int = 20;
			
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0xFF00);
			switch(type){
				case BLOCK_TYPE_EXPRESSION:
					BlockDrawer.drawExpression(g, w, h);
					break;
				case BLOCK_TYPE_STATEMENT:
					BlockDrawer.drawStatement(g, w, h);
					break;
				case BLOCK_TYPE_BREAK:
				case BLOCK_TYPE_CONTINUE:
					BlockDrawer.drawStatement(g, w, h, false);
					break;
				case BLOCK_TYPE_FOR:
					BlockDrawer.drawFor(g, w, h, getSub1Height());
					break;
				case BLOCK_TYPE_IF:
					BlockDrawer.drawIfElse(g, w, h, getSub1Height(), getSub2Height());
					break;
			}
			g.endFill();
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
			drawBg();
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
			notifyChildChanged();
		}
		
		public function notifyChildChanged():void
		{
			var b:BlockBase = this;
			while(b != null){
				b.layoutChildren();
				b.drawBg();
				if(b.isSubBlock()){
					break;
				}
				b = b.parentBlock;
			}
		}
		
		public function setPositionBySub1(child:BlockBase):void
		{
			x = child.x - BlockDrawer.armW;
			y = child.y - getPositionSub1();
		}
		
		public function setPositionBySub2(child:BlockBase):void
		{
			x = child.x - BlockDrawer.armW;
			y = child.y - getPositionSub2();
		}
		
		public function layoutSubBlock():void
		{
			if(subBlock1 != null){
				subBlock1.doLayout(x + BlockDrawer.armW, y + getPositionSub1());
				subBlock1.layoutAfterInsertBelow();
			}
			if(subBlock2 != null){
				subBlock2.doLayout(x + BlockDrawer.armW, y + getPositionSub2());
				subBlock2.layoutAfterInsertBelow();
			}
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
			_totalWidth = offsetX;
		}
		
		public function dragBegin():void
		{
			if(isExpression()){
				removeFromParentBlock();
			}else{
				var topParent:BlockBase = topBlock.parentBlock;
				prevBlock = null;
				if(parentBlock != null){
					switch(this){
						case parentBlock.subBlock1:
							parentBlock.subBlock1 = null;
							break;
						case parentBlock.subBlock2:
							parentBlock.subBlock2 = null;
							break;
					}
				}
				if(topParent != null){
					topParent.redrawControlBlockRecursively();
				}
			}
			swapToTopLayer();
		}
		
		private function getArgCount():int
		{
			var result:int = 0;
			for(var i:int=0; i<defaultArgBlockList.length; ++i){
				var argBlock:BlockBase = argBlockList[i];
				if(argBlock != null){
					result += 1 + argBlock.getArgCount();
				}
			}
			return result;
		}
		
		private function swapToTopLayer():void
		{
			var topIndex:int = parent.numChildren - 1;
			if(parent.getChildIndex(this) + getArgCount() == topIndex){
				return;
			}
			parent.setChildIndex(this, topIndex);
			for(var i:int=0; i<defaultArgBlockList.length; ++i){
				var argBlock:BlockBase = argBlockList[i];
				if(argBlock != null){
					argBlock.swapToTopLayer();
				}
			}
		}
		
		public function redrawControlBlockRecursively():void
		{
			var topParent:BlockBase = this;
			do{
				topParent.redrawControlBlock();
				topParent = topParent.topBlock.parentBlock;
			}while(topParent != null);
		}
		
		public function redrawControlBlock():void
		{
			drawBg();
			layoutSubBlock();
			layoutAfterInsertBelow();
		}
		
		public function isNearTo(px:Number, py:Number):Boolean
		{
			return Math.abs(x - px) <= 10 && Math.abs(y - py) <= 10;
		}
	}
}