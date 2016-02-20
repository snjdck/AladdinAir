package blockly
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class MenuPart extends Sprite
	{
		private var selectItem:MenuPartItem;
		
		public function MenuPart(blockDict:Object)
		{
			init(blockDict);
		}
		
		private function init(blockDict:Object):void
		{
			var xml:XMLList = <xml>
<category id="1" name="Motion" color="0x4a6cd4"/>
<category id="2" name="Looks" color="0x8a55d7"/>
<category id="3" name="Sound" color="0xbb42c3"/>
<category id="4" name="Pen" color="0x0e9a6c"/>
<category id="9" name="Data&Blocks" color="0xEE7D16"/>
<category id="5" name="Events" color="0xc88330"/>
<category id="6" name="Control" color="0xe1a91a"/>
<category id="7" name="Sensing" color="0x2ca5e2"/>
<category id="8" name="Operators" color="0x5cb712"/>
<category id="10" name="Robots" color="0x0a8698"/>
</xml>.children();
			
			for(var i:int=0; i<10; ++i){
				var itemData:XML = xml[i];
				var item:MenuPartItem = new MenuPartItem(itemData.@name, parseInt(itemData.@color), blockDict[itemData.@name]);
				if(i == 0){
					selectItem = item;
					item.setSelected(true);
				}else{
					item.setSelected(false);
				}
				item.addEventListener(MouseEvent.CLICK, __onClick);
				item.x = int(i / 5) * 200;
				item.y = (i % 5) * 20;
				addChild(item);
			}
		}
		
		private function __onClick(evt:MouseEvent):void
		{
			var item:MenuPartItem = evt.currentTarget as MenuPartItem;
			if(item == selectItem){
				return;
			}
			selectItem.setSelected(false);
			item.setSelected(true);
			selectItem = item;
		}
	}
}