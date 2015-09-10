package air.net
{
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.support.TypeCast;
	import flash.tcp.PacketSocket;
	import flash.tcp.impl.BytePacket;
	import flash.tcp.impl.JsonPacket;
	import flash.utils.ByteArray;
	
	import alex.modules.net.m.NetProxy;

	public class MainServer
	{
		static public const Instance:MainServer = new MainServer();
		
		private var socket:ServerSocket;
		private var sockList:Array = [];
		
		public function MainServer()
		{
			socket = new ServerSocket();
			socket.addEventListener(ServerSocketConnectEvent.CONNECT, __onConnect);
		}
		
		public function start(port:int):void
		{
			socket.bind(port, getLocalAddress().address);
			socket.listen();
		}
		
		public function get host():String
		{
			return socket.localAddress;
		}
		
		public function get port():int
		{
			return socket.localPort;
		}
		
		public function close():void
		{
			socket.close();
		}
		
		private function __onConnect(evt:ServerSocketConnectEvent):void
		{
			var sock:PacketSocket = new PacketSocket(new BytePacket(), evt.socket);
			sock.regNotice(NetProxy.TCP_CHAT_SEND, JsonPacket, [OnChat, sock]);
			
			var bytes:ByteArray = TypeCast.CastJsonToBytes({"id":sockList.length});
			for each(var other:PacketSocket in sockList){
				other.sendRaw(NetProxy.TCP_CHAT_MEMBER_JOIN, bytes);
			}
			
			sockList.push(sock);
			var memList:Array = [];
			for(var i:int=0; i<sockList.length; i++){
				memList.push(i.toString());
			}
			sock.sendRaw(NetProxy.TCP_CHAT_MEMBER_LIST, TypeCast.CastJsonToBytes({"list":memList}));
		}
		
		private function OnChat(packet:JsonPacket, from:PacketSocket):void
		{
			var bytes:ByteArray = TypeCast.CastJsonToBytes({"msg":packet.data.msg});
			for each(var sock:PacketSocket in sockList){
				sock.sendRaw(NetProxy.TCP_CHAT_RECV, bytes);
			}
		}
	}
}