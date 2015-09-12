package
{
	import flash.display.Sprite;
	import flash.filesystem.File;
	import flash.filesystem.FileUtil;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import alex.AppEntry;
	
	[SWF(width=1000, height=600)]
	public class TestNet extends Sprite//AppEntry
	{
		private var rootDir:File;
		
		public function TestNet()
		{
			rootDir = new File("C:/Users/dell/Adobe Flash Builder 4.7/TestNet/TestNet");
			replace(FileUtil.ReadBytes(rootDir.resolvePath("TestNet.exe")), genDllBytes(), onReplaceDll);
		}
		
		private function onReplaceDll(ba:ByteArray):void
		{
			ba.position += 4;//skip 00 00 and \\
			ba.writeMultiByte("Adobe AIR.dll", "utf-16");
			while(ba[ba.position] > 0){
				ba.writeShort(0);
			}
			FileUtil.WriteBytes(rootDir.resolvePath("TestNet_new.exe"), ba);
		}
		
		static private function replace(ba:ByteArray, bytesToFind:ByteArray, handler:Function):void
		{
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.position = 60;
			ba.position = ba.readUnsignedInt() + 6;
			var numSections:uint = ba.readUnsignedShort();
			ba.position += 12;
			var sizeOfOptionalHeader:uint = ba.readUnsignedShort();
			ba.position += 2 + sizeOfOptionalHeader;
			
			for(var i:int=0; i<numSections; ++i){
				var sectionName:String = ba.readUTFBytes(8);
				var virtualSize:uint = ba.readUnsignedInt();
				ba.position += 8;
				var sectionOffset:uint = ba.readUnsignedInt();
				ba.position += 16;
				if(sectionName == ".rdata"){
					ba.position = sectionOffset;
					var offset:int = findBytes(ba, virtualSize, bytesToFind);
					if(offset > 0){
						trace(offset.toString(16));
						ba.position = offset;
						handler(ba);
					}
					break;
				}
			}
		}
		
		static private function genDllBytes():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeShort(0);
			bytes.writeMultiByte("\\Adobe AIR\\Versions\\1.0\\Adobe AIR.dll", "utf-16");
			bytes.writeShort(0);
			return bytes;
		}
		
		static private function findBytes(source:ByteArray, size:uint, toFind:ByteArray):int
		{
			var start:int = source.position;
			var nj:int = toFind.length;
			var ni:int = size - nj + 1;
			loop:
			for(var i:int=0; i<ni; ++i){
				var offset:int = start + i;
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