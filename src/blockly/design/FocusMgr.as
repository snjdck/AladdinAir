package blockly.design
{
	import flash.display.Stage;
	import flash.events.FocusEvent;

	public class FocusMgr
	{
		public function FocusMgr(stage:Stage)
		{
			stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, __onFocusChange);
		}
		
		private function __onFocusChange(evt:FocusEvent):void
		{
			var blockArg:BlockArg = evt.target.parent as BlockArg;
			if(blockArg == null)
				return;
			setNextFocus(blockArg.block, blockArg.argIndex);
		}
		
		private function setNextFocus(block:BlockBase, argIndex:int=-1):void
		{
			if(argIndex < block.defaultArgBlockList.length - 1){
				showFocusArg(block, argIndex + 1);
			}else if(block.isExpression()){
				var parentBlock:BlockBase = block.parentBlock;
				if(parentBlock != null){
					setNextFocus(parentBlock, parentBlock.argBlockList.indexOf(block));
				}
			}else if(block.subBlock1 != null){
				setNextFocus(block.subBlock1);
			}else if(block.subBlock2 != null){
				setNextFocus(block.subBlock2);
			}else if(block.nextBlock != null){
				setNextFocus(block.nextBlock);
			}else{
				var topBlock:BlockBase = block.topBlock;
				var topParent:BlockBase = topBlock.parentBlock;
				if(topParent == null)
					return;
				if(topBlock == topParent.subBlock1 && topParent.subBlock2 != null){
					setNextFocus(topParent.subBlock2);
				}else if(topParent.nextBlock != null){
					setNextFocus(topParent.nextBlock);
				}
			}
		}
		
		private function showFocusArg(block:BlockBase, argIndex:int):void
		{
			var child:BlockBase = block.argBlockList[argIndex];
			if(child != null){
				setNextFocus(child);
			}else{
				var blockArg:BlockArg = block.defaultArgBlockList[argIndex];
				blockArg.focusOn();
			}
		}
	}
}