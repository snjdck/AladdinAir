package alex
{
	import flash.display.Sprite;
	import flash.mvc.Application;
	
	import org.aswing.AsWingManager;
	
	public class AppEntry extends Sprite
	{
		private var app:Application;
		
		public function AppEntry()
		{
			AsWingManager.initAsStandard(this);
			
			app = new NetApp(this);
			app.startup();
		}
	}
}