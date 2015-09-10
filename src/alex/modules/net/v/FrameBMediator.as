package alex.modules.net.v
{
	import flash.events.Event;
	import flash.mvc.view.Mediator;
	import flash.mvc.view.argType.ArgType;
	import flash.tcp.impl.JsonPacket;
	
	import alex.modules.net.NetModule;
	import alex.modules.net.m.NetProxy;
	import alex.modules.net.ui.FrameB;
	
	import org.aswing.AsWingUtils;
	import org.aswing.event.AWEvent;
	
	public class FrameBMediator extends Mediator
	{
		[Inject]
		public var netProxy:NetProxy;
		
		private var frameB:FrameB;
		
		public function FrameBMediator(viewComponent:Object)
		{
			super(viewComponent);
			frameB = viewComponent as FrameB;
		}
		
		override protected function onDel():void
		{
		}
		
		override protected function onReg():void
		{
			addMsgHandler(NetModule.SHOW_FRAME_B, __onShowFrame);
			addMsgHandler(NetProxy.MSG_MEMBER_UPDATE, __onMemberUpdate);
			addMsgHandler(NetProxy.MSG_RECV_CHAT, __onRecvChatMsg, ArgType.Data);
			
			addEvtHandler(frameB.sendBtn, AWEvent.ACT, __onSendMsg);
		}
		
		private function __onMemberUpdate():void
		{
			frameB.setMemberData(netProxy.memberList);
		}
		
		private function __onRecvChatMsg(msg:Object):void
		{
			frameB.chatOutput.appendText(msg.msg + "\n");
		}
		
		private function __onSendMsg(evt:Event):void
		{
			var text:String = frameB.textInput.getText();
			if(text.length <= 0){
				return;
			}
			netProxy.clientSocket.request(NetProxy.TCP_CHAT_SEND, new JsonPacket({"msg":text}));
			frameB.textInput.setText("");
		}
		
		private function __onShowFrame():void
		{
			AsWingUtils.centerLocate(frameB);
			frameB.show();
		}
		
	}
}