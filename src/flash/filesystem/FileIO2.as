package flash.filesystem
{
	import flash.utils.ByteArray;
	
	import lambda.call;

	final public class FileIO2
	{
		static private const fs:FileStream = new FileStream();
		
		static private function CastFile(fileOrPath:*):File
		{
			if(fileOrPath is File){
				return fileOrPath;
			}
			return new File(fileOrPath);
		}
		
		static public function Read(fileOrPath:*, output:ByteArray=null):ByteArray
		{
			var file:File = CastFile(fileOrPath);
			if(!file.exists){
				return null;
			}
			
			output ||= new ByteArray();
			
			fs.open(file, FileMode.READ);
			fs.readBytes(output);
			fs.close();
			
			return output;
		}
		
		static public function Write(fileOrPath:*, data:ByteArray):void
		{
			var file:File = CastFile(fileOrPath);
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		static public function Traverse(fileOrPath:*, handler:Object, fileFlag:Boolean=true, dirFlag:Boolean=false):void
		{
			if(!(fileFlag || dirFlag)){
				return;
			}
			var file:File = CastFile(fileOrPath);
			if(file.exists){
				TraverseImpl(file, handler, fileFlag, dirFlag);
			}
		}
		
		static private function TraverseImpl(file:File, handler:Object, fileFlag:Boolean, dirFlag:Boolean):Boolean
		{
			if(false == file.isDirectory){
				return fileFlag && call(handler, file);
			}else if(dirFlag && call(handler, file)){
				return true;
			}
			for each(var subFile:File in file.getDirectoryListing()){
				var stopFlag:Boolean = TraverseImpl(subFile, handler, fileFlag, dirFlag);
				if(stopFlag){
					return true;
				}
			}
			return false;
		}
		
		/** 修改文件扩展名 */
		static public function ModifyExt(fileOrPath:*, extension:String):File
		{
			var file:File = CastFile(fileOrPath);
			var filePath:String = file.nativePath;
			var index:int = filePath.lastIndexOf(".");
			if(-1 != index){
				return new File(filePath.slice(0, index+1) + extension);
			}
			return file;
		}
		
		static public function XOR(fileOrPath:*, newFileName:String, key:Array, bytePerChunk:uint=0xFFFFFFFF):Boolean
		{
			var file:File = CastFile(fileOrPath);
			
			var ba:ByteArray = Read(file);
			
			FileEncrypt.XOR(ba, ba, key, bytePerChunk);
			
			file = file.resolvePath("../" + newFileName);
			
			if(false == file.exists){
				Write(file, ba);
				return true;
			}
			
			return false;
		}
	}
}