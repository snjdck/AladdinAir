package air.net
{
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.support.TypeCast;
	import flash.tcp.PacketSocket;
	import flash.tcp.impl.BytePacket;
	import flash.tcp.impl.JsonPacket;

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
			sock.regNotice(1, JsonPacket, [OnChat, sock]);
			sockList.push(sock);
		}
		
		private function OnChat(packet:JsonPacket, from:PacketSocket):void
		{
			for each(var sock:PacketSocket in sockList){
				sock.send(2, TypeCast.CastJsonToBytes({"msg":packet.data.msg}));
				sock.flush();
			}
		}
	}
}