package flash.filesystem
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import stdlib.constant.CharSet;

	public class FileUtil
	{
		static private const fs:FileStream = new FileStream();
		
		static public function LoadFile(path:String, charSet:String=null):String
		{
			return ReadString(File.applicationDirectory.resolvePath(path), charSet);
		}
		
		static public function ReadBytes(file:File):ByteArray
		{
			var result:ByteArray = new ByteArray();
			fs.open(file, FileMode.READ);
			fs.readBytes(result);
			fs.close();
			return result;
		}
		
		static public function ReadString(file:File, charSet:String=null):String
		{
			if(null == charSet){
				charSet = CharSet.UTF_8;
			}
			fs.open(file, FileMode.READ);
			var result:String = fs.readMultiByte(fs.bytesAvailable, charSet);
			fs.close();
			return result;
		}
		
		static public function WriteString(file:File, str:String, charSet:String=null):void
		{
			if(null == charSet){
				charSet = CharSet.UTF_8;
			}
			fs.open(file, FileMode.WRITE);
			fs.writeMultiByte(str, charSet);
			fs.close();
		}
		
		static public function WriteBytes(file:File, bytes:ByteArray):void
		{
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
		}
	}
}