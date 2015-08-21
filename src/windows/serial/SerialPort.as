package windows.serial
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import array.has;
	import array.sub;
	
	import string.trim;

	[Event(name="close", type="flash.events.Event")]
	
	final public class SerialPort extends EventDispatcher
	{
		static public const Instance:SerialPort = new SerialPort();
		
		private var bytesRecv:ByteArray = new ByteArray();
		private var process:NativeProcess;
		private var info:NativeProcessStartupInfo;
		
		private var portList:Array = [];
		private var nextPortList:Array = [];
		
		public function SerialPort()
		{
			info = new NativeProcessStartupInfo();
			info.executable = new File("C:/Windows/System32/reg.exe");
			info.arguments = new <String>["query", "HKEY_LOCAL_MACHINE\\HARDWARE\\DEVICEMAP\\SERIALCOMM"];
			process = new NativeProcess();
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, __onData);
			process.addEventListener(Event.STANDARD_OUTPUT_CLOSE, __onExit);
			process.start(info);
		}
		
		private function __onData(evt:Event):void
		{
			process.standardOutput.readBytes(bytesRecv, bytesRecv.length);
		}
		
		private function __onExit(evt:Event):void
		{
			onRecv(bytesRecv.readUTFBytes(bytesRecv.bytesAvailable));
			bytesRecv.clear();
			setTimeout(process.start, 1000, info);
		}
		
		private function onRecv(data:String):void
		{
			var list:Array = trim(data).split("\r\n").slice(1);
			nextPortList.length = 0;
			for each(var item:String in list){
				var portName:String = trim(item).split(/\s+/)[2];
				nextPortList.push(portName);
			}
			list = portList;
			portList = nextPortList;
			nextPortList = list;
			notifyEvent(sub(nextPortList, portList));
		}
		
		private function notifyEvent(list:Array):void
		{
			for each(var item:String in list){
				dispatchEvent(new DataEvent(Event.CLOSE, false, false, item));
			}
		}
		
		public function getPortList():Array
		{
			return portList.slice();
		}
		
		public function isPortOpen(portName:String):Boolean
		{
			return has(portList, portName);
		}
	}
}