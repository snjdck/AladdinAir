package air.net
{
	import flash.net.InterfaceAddress;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;

	public function getLocalAddress():InterfaceAddress
	{
		var interfaceList:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
		for each(var netInterface:NetworkInterface in interfaceList){
			if(!(netInterface.active && netInterface.mtu > 0)){
				continue;
			}
			for each(var netAddress:InterfaceAddress in netInterface.addresses){
				if(Boolean(netAddress.broadcast)){
					return netAddress;
				}
			}
		}
		return null;
	}
}