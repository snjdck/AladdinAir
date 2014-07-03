package flash.udp
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	
	registerClassAlias("snjdck.net.udp::RoomInfo", RoomInfo);

	public class RoomInfo
	{
		public var name:String;
		public var builderName:String;
		
		public var maxPlayerCount:int;
		public var remainPlayerCount:int;
		
		public var port:int;
		
		public function RoomInfo()
		{
		}
		
		public function toByteArray():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(this);
			return bytes;
		}
	}
}