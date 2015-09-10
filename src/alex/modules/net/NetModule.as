package alex.modules.net
{
	import flash.mvc.Module;
	import flash.mvc.notification.MsgName;
	
	import alex.modules.net.m.NetProxy;
	import alex.modules.net.ui.FrameA;
	import alex.modules.net.ui.FrameB;
	import alex.modules.net.v.FrameAMediator;
	import alex.modules.net.v.FrameBMediator;
	
	public class NetModule extends Module
	{
		static public const SHOW_FRAME_A:MsgName = new MsgName();
		static public const SHOW_FRAME_B:MsgName = new MsgName();
		
		public function NetModule()
		{
		}
		
		override public function initAllControllers():void
		{
		}
		
		override public function initAllModels():void
		{
			regProxy(NetProxy);
		}
		
		override public function initAllServices():void
		{
		}
		
		override public function initAllViews():void
		{
			mapView(new FrameA(), FrameAMediator);
			mapView(new FrameB(), FrameBMediator);
		}
		
		override public function onStartup():void
		{
			notify(SHOW_FRAME_A);
		}
		
	}
}