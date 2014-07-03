package flash.udp
{
	import flash.events.DatagramSocketDataEvent;
	import flash.net.DatagramSocket;
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	final public class UdpSocket
	{
		static public const PORT:int = 2501;
		
		private var handlerDict:Object = new Dictionary();
		private var socket:DatagramSocket;
		
		public function UdpSocket()
		{
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
			send(data, "192.168.0.255");
		}
		
		public function regHandler(msgId:int, handler:Function):void
		{
			handlerDict[msgId] = handler;
		}
		
		private function __onData(evt:DatagramSocketDataEvent):void
		{
			var address:String = evt.srcAddress;
			
			if(isLocal(address)){
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
			var bytes:ByteArray = createBytes();
			if(obj is String){
				bytes.writeUTF(obj as String);
			}else{
				bytes.writeObject(obj);
			}
			return bytes;
		}
		
		static public function createBytes():ByteArray
		{
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.LITTLE_ENDIAN;
			return ba;
		}
		
		static public function isLocal(address:String):Boolean
		{
			var interfaceList:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
			for each(var netInterface:NetworkInterface in interfaceList){
				for each(var netAddress:InterfaceAddress in netInterface.addresses){
					if(netAddress.address == address){
						return true;
					}
				}
			}
			return false;
		}
	}
}