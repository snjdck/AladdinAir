package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileUtil;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	[SWF(width=1000, height=600)]
	public class TestNet extends Sprite
	{
		public function TestNet()
		{
			var rootDir:File = new File("E:/test");
			
			var exeBytes:ByteArray = FileUtil.ReadBytes(rootDir.resolvePath("Main.exe"));
			var dllBytes:ByteArray = FileUtil.ReadBytes(rootDir.resolvePath("Adobe AIR/Versions/1.0/Adobe AIR.dll"));
			
			replace(exeBytes, genUtf_16("\\Adobe AIR\\Versions\\1.0\\Adobe AIR.dll"), "\\AdobeRuntime\\Adobe AIR.dll");
			replace(dllBytes, genUtf_16("\\Resources"), "\\.");
			replace(dllBytes, genUtf_8("META-INF/AIR/application.xml"), "AdobeRuntime/application.xml");
			replace(dllBytes, genUtf_8("META-INF/AIR/extensions"), "AdobeRuntime/extensions");
			
			FileUtil.WriteBytes(rootDir.resolvePath("MainTest.exe"), exeBytes);
			FileUtil.WriteBytes(rootDir.resolvePath("AdobeRuntime/Adobe AIR.dll"), dllBytes);
		}
		
		static private function onReplaceUtf_8(ba:ByteArray, endPos:int, replaceStr:String):void
		{
			ba.writeUTFBytes(replaceStr);
			while(ba.position < endPos){
				ba.writeByte(0);
			}
		}
		
		static private function onReplaceUtf_16(ba:ByteArray, replaceStr:String):void
		{
			ba.writeMultiByte(replaceStr, "utf-16");
			while(ba[ba.position] > 0){
				ba.writeShort(0);
			}
		}
		
		static private function replace(ba:ByteArray, bytesToFind:ByteArray, replaceStr:String):void
		{
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.position = 60;
			ba.position = ba.readUnsignedInt() + 6;
			const numSections:uint = ba.readUnsignedShort();
			ba.position += 12;
			
			const offsetOptionalHeader:uint = ba.position + 4;
			const sizeOfOptionalHeader:uint = ba.readUnsignedShort();
			ba.position += 2 + sizeOfOptionalHeader;
			
			var rdataInfo:Array;
			var tailOffset:uint = 0;
			for(var i:int=0; i<numSections; ++i){
				var sectionName:String = ba.readUTFBytes(8);
				var virtualSize:uint = ba.readUnsignedInt();
				ba.position += 4;
				var sectionSize:uint = ba.readUnsignedInt();
				var sectionOffset:uint = ba.readUnsignedInt();
				ba.position += 16;
				tailOffset = sectionOffset + sectionSize;
				if(sectionName == ".rdata"){
					rdataInfo = [sectionOffset, virtualSize];
				}
			}
			if(tailOffset < ba.length){
				ba.position = tailOffset;
				var signSize:int = ba.readUnsignedShort();
				ba.position = findBytes(ba, offsetOptionalHeader, sizeOfOptionalHeader, genSignBytes(tailOffset, signSize));
				clearSignInfo(ba);
				ba.length = tailOffset;
			}
			for(;;){
				var offset:int = findBytes(ba, rdataInfo[0], rdataInfo[1], bytesToFind);
				if(offset < 0){
					break;
				}
				trace(offset.toString(16));
				if(ba[offset] > 0){
					ba.position = offset;
					onReplaceUtf_8(ba, offset + bytesToFind.length, replaceStr);
				}else{
					ba.position = offset + 2;
					onReplaceUtf_16(ba, replaceStr);
				}
			}
		}
		
		static private function clearSignInfo(ba:ByteArray):void
		{
			ba.writeUnsignedInt(0);
			ba.writeShort(0);
		}
		
		static private function genSignBytes(tailOffset:uint, signSize:int):ByteArray
		{
			var signBytes:ByteArray = new ByteArray();
			signBytes.endian = Endian.LITTLE_ENDIAN;
			signBytes.writeUnsignedInt(tailOffset);
			signBytes.writeShort(signSize);
			return signBytes;
		}
		
		static private function genUtf_8(str:String):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeUTFBytes(str);
			return bytes;
		}
		
		static private function genUtf_16(str:String):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeShort(0);
			bytes.writeMultiByte(str, "utf-16");
			bytes.writeShort(0);
			return bytes;
		}
		
		static private function findBytes(source:ByteArray, from:uint, size:uint, toFind:ByteArray):int
		{
			var nj:int = toFind.length;
			var ni:int = size - nj + 1;
			loop:
			for(var i:int=0; i<ni; ++i){
				var offset:int = from + i;
				for(var j:int=0; j<nj; ++j){
					if(toFind[j] != source[offset+j]){
						continue loop;
					}
				}
				return offset;
			}
			return -1;
		}
	}
}