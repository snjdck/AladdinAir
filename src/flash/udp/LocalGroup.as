package flash.udp
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	/**
	 * 局域网,本地组
	 */	
	public class LocalGroup
	{
		private var nc:NetConnection;
		private var ng:NetGroup;
		
		private const handlerDict:Object = {};
		
		public function LocalGroup()
		{
			addHandler("NetConnection.Connect.Success",	initNetGroup);
			addHandler("NetGroup.Connect.Rejected",		null);
			addHandler("NetGroup.Connect.Failed",		null);
			addHandler("NetGroup.Connect.Success",		null);
			addHandler("NetGroup.Neighbor.Connect",		onPeerConnect);
			addHandler("NetGroup.Neighbor.Disconnect",	onPeerDisconnect);
			addHandler("NetGroup.Posting.Notify",		onPeerMsgRecv);
			addHandler("NetGroup.SendTo.Notify",		onPeerMsgRecv);
			
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS, __onNetStatus);
			nc.connect("rtmfp:");
		}
		
		private function addHandler(infoCode:String, handler:Function):void
		{
			handlerDict[infoCode] = handler;
		}
		
		private function createGroupSpecifier(name:String, address:String):String
		{
			var gs:GroupSpecifier = new GroupSpecifier(name);
			gs.ipMulticastMemberUpdatesEnabled = true;
			gs.objectReplicationEnabled = true;
			gs.postingEnabled = true;
			gs.routingEnabled = true;
			gs.addIPMulticastAddress(address);
			return gs.groupspecWithAuthorizations();
		}
		
		private function __onNetStatus(evt:NetStatusEvent):void
		{
			var info:Object = evt.info;
			var handler:Function = handlerDict[info.code];
			if(null != handler){
				handler(info);
			}else{
				trace(info.code);
			}
		}
		
		private function initNetGroup(info:Object):void
		{
			ng = new NetGroup(nc, createGroupSpecifier("myg/gone", "224.0.0.254:30000"));
			ng.addEventListener(NetStatusEvent.NET_STATUS, __onNetStatus);
		}
		
		private function onPeerMsgRecv(info:Object):void
		{
			var msg:Object = info.message;
			var fromGroupAddress:String = info.from;
			var isFromLocal:Boolean = info.fromLocal;
		}
		
		private function onPeerConnect(info:Object):void
		{
			var neighborPeerID:String = info.peerID;
			var neighborGroupAddress:String = info.neighbor;
		}
		
		private function onPeerDisconnect(info:Object):void
		{
			var neighborPeerID:String = info.peerID;
			var neighborGroupAddress:String = info.neighbor;
		}
	}
}