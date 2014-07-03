package flash.udp
{
	import flash.utils.ByteArray;

	public class WarSocket
	{
		static public const ID_SEARCH	:uint = 0x00102FF7;
		static public const ID_END		:uint = 0x000833F7;
		static public const ID_LAN		:uint = 0x001032F7;
		static public const ID_MAP		:uint = 0x008B30F7;
		
		static public const VERSION:uint = 23;
		
		private var socket:UdpSocket;
		private var roomDict:Object = {};
		private var roomInfo:RoomInfo;
		
		public function WarSocket()
		{
			socket = new UdpSocket();
			socket.regHandler(ID_SEARCH, __onSearch);
			socket.regHandler(ID_END, __onEnd);
			socket.regHandler(ID_LAN, __onLan);
			socket.regHandler(ID_MAP, __onMap);
		}
		
		private function get isRoomBuilded():Boolean
		{
			return roomInfo != null;
		}
		
		public function buildRoom(name:String):void
		{
			roomInfo = new RoomInfo();
			roomInfo.name = name;
			sendLanPacket(0, 0);
		}
		
		public function closeRoom():void
		{
			roomInfo = null;
		}
		
		/**
		 * 有玩家请求房间信息
		 * @param address
		 * @param bytes
		 */	
		private function __onSearch(address:String, bytes:ByteArray):void
		{
			if(false == isRoomBuilded){
				return;
			}
			sendMap(address, 0, roomInfo);
		}
		
		/**
		 * 有玩家关闭房间,或开始游戏
		 * @param address
		 * @param bytes
		 */		
		private function __onEnd(address:String, bytes:ByteArray):void
		{
			delete roomDict[address];
			printAllMaps();
		}
		
		/**
		 * 有玩家创建房间
		 * @param address
		 * @param bytes
		 */		
		private function __onLan(address:String, bytes:ByteArray):void
		{
			sendSearchPacket(address, 0);
		}
		
		/**
		 * 收到房间信息
		 * @param address
		 * @param bytes
		 */		
		private function __onMap(address:String, bytes:ByteArray):void
		{
			var countTag:uint = bytes.readUnsignedInt();
			roomDict[address] = bytes.readObject();
			printAllMaps();
		}
		
		private function printAllMaps():void
		{
			trace("======roomInfo======");
			for each(var roomInfo:RoomInfo in roomDict){
				trace(roomInfo.name);
			}
		}
		
		private function sendSearchPacket(address:String, countTag:uint):void
		{
			var bytes:ByteArray = UdpSocket.createBytes();
			bytes.writeUnsignedInt(ID_SEARCH);
			bytes.writeUTFBytes("PX3W");
			bytes.writeUnsignedInt(VERSION);
			bytes.writeUnsignedInt(countTag);
			socket.send(bytes, address);
		}
		
		private function sendMap(address:String, countTag:uint, roomInfo:RoomInfo):void
		{
			var bytes:ByteArray = UdpSocket.createBytes();
			bytes.writeUnsignedInt(ID_MAP);
			bytes.writeUnsignedInt(countTag);
			bytes.writeBytes(roomInfo.toByteArray());
			socket.send(bytes, address);
		}
		
		private function sendLanPacket(countTag:uint, remainCount:uint):void
		{
			var bytes:ByteArray = UdpSocket.createBytes();
			bytes.writeUnsignedInt(ID_LAN);
			bytes.writeUnsignedInt(countTag);
			bytes.writeUnsignedInt(1);
			bytes.writeUnsignedInt(1 + remainCount);
			socket.sendToAll(bytes);
		}
		
		private function sendCloseRoomPacket(countTag:uint):void
		{
			var bytes:ByteArray = UdpSocket.createBytes();
			bytes.writeUnsignedInt(ID_END);
			bytes.writeUnsignedInt(countTag);
			socket.sendToAll(bytes);
		}
	}
}