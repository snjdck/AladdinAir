package iot
{
	public class CirclePointOut extends CirclePoint
	{
		public const linkedInPtList:Vector.<CirclePointIn> = new Vector.<CirclePointIn>();
		
		public function CirclePointOut()
		{
			super(false);
		}
		
		public function addInPt(value:CirclePointIn):void
		{
			linkedInPtList.push(value);
		}
		
		public function removePt(value:CirclePointIn):void
		{
			var index:int = linkedInPtList.indexOf(value);
			if(index >= 0){
				linkedInPtList.splice(index, 1);
			}
		}
	}
}