package blockly.blocks
{
	import blockly.design.ArduinoOutput;
	import blockly.design.MyBlock;
	
	import string.replace;
	
	public class RunMotorBlock extends MyBlock
	{
		public function RunMotorBlock()
		{
		}
		
		override protected function onGenArduinoStatement(result:ArduinoOutput, argList:Array, indent:int):void
		{
			result.addVarDefine("MeDCMotor", replace("motor_${0}(${0})", argList));
			result.addCode(replace("motor_${0}.run((${0})==M1?-({1}):({1}));", argList), indent);
		}
	}
}