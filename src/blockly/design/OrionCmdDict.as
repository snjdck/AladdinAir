package blockly.design
{
	import string.replace;

	public class OrionCmdDict extends ArduinoCmdDict
	{
		public function OrionCmdDict()
		{
			addCmd("add", __onAdd);
			addCmd("runMotor", __onRunMotor);
		}
		
		private function __onAdd(output:ArduinoOutput, cmd:String, argList:Array, indent:int):String
		{
			return argList[0] + " + " + argList[1];
		}
		
		private function __onRunMotor(output:ArduinoOutput, cmd:String, argList:Array, indent:int):void
		{
			output.addVarDefine("MeDCMotor", replace("motor_${0}(${0})", argList));
			output.addCode(replace("motor_${0}.run((${0})==M1?-({1}):({1}));", argList), indent);
		}
	}
}