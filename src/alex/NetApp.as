package alex
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.mvc.Application;
	
	import alex.modules.net.NetModule;
	
	public class NetApp extends Application
	{
		public function NetApp(root:Sprite)
		{
			getInjector().mapValue(Sprite, root, null, false);
			getInjector().mapValue(Stage, root.stage, null, false);
			
			regModule(new NetModule());
		}
	}
}