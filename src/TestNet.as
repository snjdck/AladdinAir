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
		private var rootDir:File;
		
		public function TestNet()
		{
			rootDir = new File("E:/release");
			replace(FileUtil.ReadBytes(rootDir.resolvePath("test.exe")), genDllBytes(), onReplaceDll);
		}
		
		private function onReplaceDll(ba:ByteArray):void
		{
			ba.position += 4;//skip 00 00 and \\
			ba.writeMultiByte("Adobe AIR.dll", "utf-16");
			while(ba[ba.position] > 0){
				ba.writeShort(0);
			}
			FileUtil.WriteBytes(rootDir.resolvePath("testNew.exe"), ba);
		}
		
		static private function replace(ba:ByteArray, bytesToFind:ByteArray, handler:Function):void
		{
			ba.endian = Endian.LITTLE_ENDIAN;
			ba.position = 60;
			ba.position = ba.readUnsignedInt() + 6;
			const numSections:uint = ba.readUnsignedShort();
			ba.position += 12;
			
			const offsetOptionalHeader:uint = ba.position + 4;
			const sizeOfOptionalHeader:uint = ba.readUnsignedShort();
			ba.position += 2 + sizeOfOptionalHeader;
			
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
					var prevPos:uint = ba.position;
					var offset:int = findBytes(ba, sectionOffset, virtualSize, bytesToFind);
					if(offset > 0){
						trace(offset.toString(16));
						ba.position = offset;
						handler(ba);
					}
					ba.position = prevPos;
				}
			}
			if(tailOffset < ba.length){
				ba.position = tailOffset;
				var signSize:int = ba.readUnsignedShort();
				ba.position = findBytes(ba, offsetOptionalHeader, sizeOfOptionalHeader, genSignBytes(tailOffset, signSize));
				clearSignInfo(ba);
				ba.length = tailOffset;
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
		
		static private function genDllBytes():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeShort(0);
			bytes.writeMultiByte("\\Adobe AIR\\Versions\\1.0\\Adobe AIR.dll", "utf-16");
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