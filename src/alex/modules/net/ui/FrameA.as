package alex.modules.net.ui
{
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.SoftBoxLayout;
	
	public class FrameA extends JFrame
	{
		public var createBtn:JButton;
		public var joinBtn:JButton;
		
		private var serverList:JList;
		
		public function FrameA(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			setResizable(false);
			
			serverList = new JList();
			serverList.setPreferredWidth(100);
			
			var btnList:JPanel = new JPanel(new SoftBoxLayout(SoftBoxLayout.Y_AXIS));
			createBtn = new JButton("创建");
			joinBtn = new JButton("加入");
			btnList.appendAll(createBtn, joinBtn);
			
			getContentPane().append(serverList, BorderLayout.CENTER);
			getContentPane().append(btnList, BorderLayout.EAST);
			
			setSizeWH(550, 400);
		}
		
		public function setServerList(value:Array):void
		{
			serverList.setListData(value);
		}
		
		public function getSelectedItem():String
		{
			return serverList.getSelectedValue();
		}
	}
}