package alex.modules.net.m
{
	import flash.mvc.model.Proxy;
	import flash.mvc.notification.MsgName;
	import flash.tcp.PacketSocket;
	import flash.tcp.impl.BytePacket;
	import flash.tcp.impl.JsonPacket;
	import flash.udp.LocalGroup;
	import flash.udp.LocalGroupEvent;
	
	import air.net.MainServer;
	
	public class NetProxy extends Proxy
	{
		static public const MSG_SERVER_LIST_UPDATE:MsgName = new MsgName();
		static public const MSG_RECV_CHAT:MsgName = new MsgName();
		static public const MSG_MEMBER_UPDATE:MsgName = new MsgName();
		
		static public const UDP_SERVER_OPEN:int = 1;
		static public const UDP_SERVER_CLOSE:int = 2;
		
		static public const TCP_CHAT_SEND:uint = 1;
		static public const TCP_CHAT_RECV:uint = 2;
		static public const TCP_CHAT_MEMBER_LIST:uint = 3;
		static public const TCP_CHAT_MEMBER_JOIN:uint = 4;
		static public const TCP_CHAT_MEMBER_LEAVE:uint = 5;
		
		private var group:LocalGroup;
		
		private var server:MainServer;
		public var clientSocket:PacketSocket;
		public var serverList:Array = [];
		
		public var memberList:Array;
		
		public function NetProxy()
		{
			group = new LocalGroup(LocalGroup.createGroupSpecifier("myg/gone", "224.0.0.254", 30000));
			group.addEventListener(LocalGroupEvent.CONNECT, __onConnect);
			group.addEventListener(LocalGroupEvent.DISCONNECT, __onClose);
			group.addEventListener(LocalGroupEvent.MESSAGE, __onData);
		}
		
		private function __onConnect(evt:LocalGroupEvent):void
		{
			if(server != null){
				group.sendTo({"type":UDP_SERVER_OPEN, "ip":server.host, "port":server.port}, evt.address);
			}
		}
		
		private function __onClose(evt:LocalGroupEvent):void
		{
		}
		
		private function __onData(evt:LocalGroupEvent):void
		{
			switch(evt.msg.type){
				case UDP_SERVER_OPEN:
					serverList.push(evt.msg.ip + ":" + evt.msg.port);
					notify(MSG_SERVER_LIST_UPDATE);
					break;
			}
		}
		
		public function startServer(callback:Function):void
		{
			server = new MainServer();
			server.start(7410);
			group.sendToAll({"type":UDP_SERVER_OPEN, "ip":server.host, "port":server.port});
			joinServer(server.host+":"+server.port, callback);
		}
		
		public function joinServer(host:String, callback:Function):void
		{
			if(null == clientSocket){
				clientSocket = new PacketSocket(new BytePacket());
				clientSocket.connect2(host);
				clientSocket.connectSignal.add(callback, true);
				clientSocket.regRequest(TCP_CHAT_SEND, JsonPacket);
				clientSocket.regNotice(TCP_CHAT_RECV, JsonPacket, __onChatDataRecv);
				clientSocket.regNotice(TCP_CHAT_MEMBER_LIST, JsonPacket, __onMemberInit);
				clientSocket.regNotice(TCP_CHAT_MEMBER_JOIN, JsonPacket, __onMemberJoin);
			}
		}
		
		private function __onChatDataRecv(info:JsonPacket):void
		{
			notify(MSG_RECV_CHAT, info.data);
		}
		
		private function __onMemberInit(info:JsonPacket):void
		{
			memberList = info.data.list;
			notify(MSG_MEMBER_UPDATE);
		}
		
		private function __onMemberJoin(info:JsonPacket):void
		{
			memberList.push(info.data.id);
			notify(MSG_MEMBER_UPDATE);
		}
	}
}