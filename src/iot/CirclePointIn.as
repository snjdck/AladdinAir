package iot
{
	public class CirclePointIn extends CirclePoint
	{
		public var linkedOutPt:CirclePointOut;
		
		public function CirclePointIn()
		{
			super(true);
		}
		
		public function hasOutPt():Boolean
		{
			return linkedOutPt != null;
		}
	}
}