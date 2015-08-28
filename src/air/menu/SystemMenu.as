package air.menu
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.Stage;
	import flash.events.Event;

	public class SystemMenu
	{
		private const handlerDict:Object = {};
		private var menu:NativeMenu;
		protected var defaultMenuCount:int;
		
		public function SystemMenu(stage:Stage, source:XML)
		{
			menu = MenuBuilder.BuildMenu(source);
			if(NativeApplication.supportsMenu){
				defaultMenuCount = 1;
				onAddAppMenu(menu);
			}else if(NativeWindow.supportsMenu){
				stage.nativeWindow.menu = menu;
			}
			menu.addEventListener(Event.SELECT, __onSelect);
		}
		
		private function onAddAppMenu(menu:NativeMenu):void
		{
			var appMenu:NativeMenu = NativeApplication.nativeApplication.menu;
			while(appMenu.numItems > defaultMenuCount){
				appMenu.removeItemAt(appMenu.numItems-1);
			}
			while(menu.numItems > 0){
				appMenu.addItem(menu.removeItemAt(0));
			}
			menu = appMenu;
		}
		
		private function __onSelect(evt:Event):void
		{
			var menuItem:NativeMenuItem = evt.target as NativeMenuItem;
			
			var handler:Function = handlerDict[menuItem.name];
			if(null != handler){
				handler(menuItem);
				return;
			}
			
			var testItem:NativeMenuItem = menuItem;
			for(;;){
				testItem = MenuUtil.FindParentItem(testItem);
				if(null == testItem){
					return;
				}
				handler = handlerDict[testItem.name];
				if(null != handler){
					handler(menuItem);
					return;
				}
			}
		}
		
		public function getNativeMenu():NativeMenu
		{
			return menu;
		}
		
		public function register(menuName:String, handler:Function):void
		{
			handlerDict[menuName] = handler;
		}
	}
}