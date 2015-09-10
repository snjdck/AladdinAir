package alex.modules.net.v
{
	import flash.events.Event;
	import flash.mvc.view.Mediator;
	
	import alex.modules.net.NetModule;
	import alex.modules.net.m.NetProxy;
	import alex.modules.net.ui.FrameA;
	
	import org.aswing.AsWingUtils;
	import org.aswing.event.AWEvent;
	import org.aswing.event.ListItemEvent;
	
	public class FrameAMediator extends Mediator
	{
		[Inject]
		public var netProxy:NetProxy;
		
		private var frameA:FrameA;
		
		public function FrameAMediator(viewComponent:Object)
		{
			super(viewComponent);
			frameA = viewComponent as FrameA;
		}
		
		override protected function onDel():void
		{
		}
		
		override protected function onReg():void
		{
			addMsgHandler(NetModule.SHOW_FRAME_A, __onShowFrame);
			addMsgHandler(NetProxy.MSG_SERVER_LIST_UPDATE, __onServerListUpdate);
			addEvtHandler(frameA.createBtn, AWEvent.ACT, __onCreateServer);
			addEvtHandler(frameA.joinBtn, AWEvent.ACT, __onJoinServer);
		}
		
		private function __onJoinServer(evt:Event):void
		{
			var host:String = frameA.getSelectedItem();
			if(!Boolean(host)){
				return;
			}
			netProxy.joinServer(host, __onConnectToServer);
		}
		
		private function __onCreateServer(evt:Event):void
		{
			netProxy.startServer(__onConnectToServer);
		}
		
		private function __onConnectToServer():void
		{
			notify(NetModule.SHOW_FRAME_B);
			frameA.hide();
		}
		
		private function __onShowFrame():void
		{
			AsWingUtils.centerLocate(frameA);
			frameA.show();
		}
		
		private function __onServerListUpdate():void
		{
			frameA.setServerList(netProxy.serverList);
		}
	}
}