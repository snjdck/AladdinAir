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
		
		public function SystemMenu(stage:Stage, source:XML)
		{
			menu = MenuBuilder.BuildMenu(source);
			if(NativeApplication.supportsMenu){
				NativeApplication.nativeApplication.menu = menu;
			}else if(NativeWindow.supportsMenu){
				stage.nativeWindow.menu = menu;
			}
			menu.addEventListener(Event.SELECT, __onSelect);
		}
		
		private function __onSelect(evt:Event):void
		{
			var menuItem:NativeMenuItem = evt.target as NativeMenuItem;
			var handler:Function = handlerDict[menuItem.name];
			if(null != handler){
				handler(menuItem);
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