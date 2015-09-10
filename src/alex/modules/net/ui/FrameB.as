package alex.modules.net.ui
{
	import org.aswing.BorderLayout;
	import org.aswing.JButton;
	import org.aswing.JFrame;
	import org.aswing.JList;
	import org.aswing.JPanel;
	import org.aswing.JTextArea;
	import org.aswing.JTextField;
	
	public class FrameB extends JFrame
	{
		public var chatOutput:JTextArea;
		public var memberList:JList;
		public var textInput:JTextField;
		public var sendBtn:JButton;
		
		public function FrameB(owner:*=null, title:String="", modal:Boolean=false)
		{
			super(owner, title, modal);
			
			memberList = new JList();
			memberList.setPreferredWidth(100);
			
			chatOutput = new JTextArea();
			
			var bottomGroup:JPanel = new JPanel(new BorderLayout());
			textInput = new JTextField();
			sendBtn = new JButton("发送");
			bottomGroup.append(textInput, BorderLayout.CENTER);
			bottomGroup.append(sendBtn, BorderLayout.EAST);
			
			var leftGroup:JPanel = new JPanel(new BorderLayout());
			leftGroup.append(chatOutput, BorderLayout.CENTER);
			leftGroup.append(bottomGroup, BorderLayout.SOUTH);
			
			getContentPane().append(leftGroup, BorderLayout.CENTER);
			getContentPane().append(memberList, BorderLayout.EAST);
			
			setSizeWH(550, 400);
		}
		
		public function setMemberData(value:Array):void
		{
			memberList.setListData(value);
		}
	}
}