package air.net
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.support.CmdParser;
	import flash.support.TypeCast;
	import flash.tcp.PacketSocket;
	import flash.tcp.impl.BytePacket;
	import flash.tcp.impl.JsonPacket;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.udp.LocalGroup;
	import flash.udp.LocalGroupEvent;
	import flash.ui.Keyboard;
	
	import string.htmlText;
	
	public class BaseNetApp extends Sprite
	{
		static public const UDP_CHAT:int = 1;
		static public const UDP_SERVER_INFO:int = 2;
		
		
		private var group:LocalGroup;
		private var tf:TextField;
		private var input:TextField;
		private var serverListView:TextField;
		
		private var server:MainServer;
		private var parser:CmdParser = new CmdParser();
		private var serverList:Array = [];
		private var clientSocket:PacketSocket;
		
		public function BaseNetApp()
		{
			parser.regCmd("startServer", function(port:int):void{
				if(null == server){
					server = new MainServer();
					server.start(7410);
					group.sendToAll({"type":UDP_SERVER_INFO, "ip":server.host, "port":server.port});
					serverList.push(server.host + ":" + server.port);
					updateServerList();
				}
				trace("funck",port);
			});
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			group = new LocalGroup(LocalGroup.createGroupSpecifier("myg/gone", "224.0.0.254", 30000));
			group.addEventListener(LocalGroupEvent.CONNECT, __onConnect);
			group.addEventListener(LocalGroupEvent.DISCONNECT, __onClose);
			group.addEventListener(LocalGroupEvent.MESSAGE, __onData);
			
			tf = new TextField();
			tf.defaultTextFormat = new TextFormat("宋体", 12);
			tf.autoSize = TextFieldAutoSize.LEFT;
			addChild(tf);
			
			input = new TextField();
			input.defaultTextFormat = new TextFormat("宋体", 12);
			input.type = TextFieldType.INPUT;
			input.border = true;
			input.width = 200;
			input.y = stage.stageHeight - input.height - 2;
			addChild(input);
			
			serverListView = new TextField();
			serverListView.defaultTextFormat = new TextFormat("宋体", 12);
			serverListView.autoSize = TextFieldAutoSize.LEFT;
			serverListView.x = 500;
			serverListView.addEventListener(TextEvent.LINK, __onLink);
			addChild(serverListView);
			
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
		}
		
		private function __onConnect(evt:LocalGroupEvent):void
		{
			tf.appendText(evt.address + " 加入聊天室\n");
			if(server != null){
				group.sendTo({"type":UDP_SERVER_INFO, "ip":server.host, "port":server.port}, evt.address);
			}
		}
		
		private function __onClose(evt:LocalGroupEvent):void
		{
			tf.appendText(evt.address + " 离开聊天室\n");
		}
		
		private function __onKeyDown(evt:KeyboardEvent):void
		{
			if(evt.keyCode != Keyboard.ENTER){
				return;
			}
			if(!Boolean(input.text)){
				return;
			}
			
			if(parser.isValidCmd(input.text)){
				parser.exec(input.text);
				input.text = "";
				return;
			}
			
			if(clientSocket != null){
				clientSocket.request(new ChatMsg({"msg":input.text}));
				input.text = "";
				return;
			}
			
			var packet:Object = {};
			packet.type = UDP_CHAT;
			packet.msg = input.text;
			
			group.sendToAll(packet);
			tf.appendText("我:" + input.text + "\n");
			input.text = "";
		}
		
		private function __onData(evt:LocalGroupEvent):void
		{
			switch(evt.msg.type){
				case UDP_CHAT:
					tf.appendText(evt.address + ":" + evt.msg.msg + "\n");
					break;
				case UDP_SERVER_INFO:
					serverList.push(evt.msg.ip + ":" + evt.msg.port);
					updateServerList();
					break;
			}
		}
		
		private function updateServerList():void
		{
			var result:String = "";
			for each(var item:String in serverList){
				result += htmlText(item).eventLink(item).newline();
			}
			trace(result);
			serverListView.htmlText = result;
		}
		
		private function __onLink(evt:TextEvent):void
		{
			if(null == clientSocket){
				clientSocket = new PacketSocket(new BytePacket());
				clientSocket.connect2(evt.text);
				clientSocket.connectSignal.add(function():void{
					tf.appendText("连接服务器成功\n");
				}, true);
				clientSocket.regRequest(1, ChatMsg);
				clientSocket.regNotice(2, JsonPacket, __onChatDataRecv);
			}
		}
		
		private function __onChatDataRecv(info:JsonPacket):void
		{
			tf.appendText("server reply:" +info.data.msg + "\n");
		}
	}
}
import flash.tcp.impl.JsonPacket;

class ChatMsg extends JsonPacket
{
	public function ChatMsg(info:Object)
	{
		data = info;
	}
}