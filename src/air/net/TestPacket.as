package air.net
{
	import flash.tcp.PacketSocket;
	import flash.tcp.impl.JsonPacket;
	
	public class TestPacket extends JsonPacket
	{
		static public const ID:int = 1;
		static public function Handle(packet:TestPacket, socket:PacketSocket):void
		{
			
		}
		
		public function TestPacket()
		{
			super();
		}
	}
}