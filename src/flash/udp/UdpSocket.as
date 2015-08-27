package flash.udp
{
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.net.InterfaceAddress;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	import air.net.getLocalAddress;
	
	final public class UdpSocket
	{
		static public var PORT:int = 2501;
		
		private var handlerDict:Object = new Dictionary();
		private var socket:DatagramSocket;
		private var localAddress:InterfaceAddress;
		
		public function UdpSocket()
		{
			localAddress = getLocalAddress();
			
			socket = new DatagramSocket();
			socket.bind(PORT);
			socket.addEventListener(DatagramSocketDataEvent.DATA, __onData);
			socket.receive();
		}
		
		public function close():void
		{
			handlerDict = null;
			socket.removeEventListener(DatagramSocketDataEvent.DATA, __onData);
			socket.close();
			socket = null;
		}
		
		public function send(data:Object, address:String):void
		{
			socket.send(obj2bytes(data), 0, 0, address, PORT);
		}
		
		public function sendToAll(data:Object):void
		{
			send(data, localAddress.broadcast);
		}
		
		public function regHandler(msgId:int, handler:Function):void
		{
			handlerDict[msgId] = handler;
		}
		
		private function __onData(evt:DatagramSocketDataEvent):void
		{
			var address:String = evt.srcAddress;
			
			if(address == localAddress.address){
				return;
			}
			
			var buffer:ByteArray = evt.data;
			buffer.endian = Endian.LITTLE_ENDIAN;
			
			var msgId:int = buffer.readUnsignedInt();
			var handler:Function = handlerDict[msgId];
			
			if(null == handler){
				trace("unsuport packet: 0x" + msgId.toString(16));
				return;
			}
			
			handler(address, buffer);
		}
		
		static private function obj2bytes(obj:Object):ByteArray
		{
			if(obj is ByteArray){
				return obj as ByteArray;
			}
			var bytes:ByteArray = new ByteArray();
			if(obj is String){
				bytes.writeUTF(obj as String);
			}else{
				bytes.writeObject(obj);
			}
			return bytes;
		}
	}
}