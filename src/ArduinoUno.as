package
{
	import com.arduino.BoardInfo;
	import com.arduino.BoardInfoFactory;
	import com.arduino.BoardType;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileIO2;
	import flash.utils.IDataInput;
	import flash.utils.setTimeout;
	
	public class ArduinoUno extends Sprite
	{
		private var sdk:File = new File("C:/Program Files (x86)/Arduino");
		private var bin:File = sdk.resolvePath("hardware/tools/avr/bin");
		
		private var libList:Array = [];
		private var taskList:Array = [];
		private var workDir:File = File.desktopDirectory.resolvePath("test");
		
		private var elf:String = "project.elf";
		private var eep:String = "project.eep";
		private var hex:String = "project.hex";
		
		private var boardInfo:BoardInfo;
		
		private var errorMsg:String;
		
		public function ArduinoUno()
		{
			boardInfo = BoardInfoFactory.GetBoardInfo(BoardType.leonardo);
			
			libList.push(sdk.resolvePath("hardware/arduino/avr/cores/arduino"));
			boardInfo.getLibList(sdk, libList);
			libList.push(sdk.resolvePath("hardware/arduino/avr/libraries/Wire"));
			libList.push(sdk.resolvePath("hardware/arduino/avr/libraries/Wire/utility"));
			libList.push(sdk.resolvePath("hardware/arduino/avr/libraries/SoftwareSerial"));
			libList.push(sdk.resolvePath("libraries/Servo/src"));
			libList.push(sdk.resolvePath("libraries/makeblock/src"));
			
			if(workDir.exists){
				workDir.deleteDirectory(true);
			}
			workDir.createDirectory();
			
			for each(var lib:File in libList){
				FileIO2.Traverse(lib, [printFiles, lib]);
			}
			
			var info:NativeProcessStartupInfo = createInfo();
			compile(info, File.desktopDirectory.resolvePath("project_9_6/project_9_6.cpp"), "project.cpp.o");
			taskList.unshift(info);
			objList.unshift("project.cpp.o");
			
			taskList.push(genLink());
			taskList.push(genElf());
			taskList.push(copyObj());
			taskList.push(copyHex());
			boardInfo.prepareUpload(taskList, "COM11");
			taskList.push(upload("COM14"));
			
			totalCount = taskList.length;
			runTask();
		}
		
		private var totalCount:int;
		
		private function __onExit(evt:NativeProcessExitEvent):void
		{
			if(evt.exitCode > 0){
				trace(evt.exitCode, errorMsg);
			}else{
				trace((1 - taskList.length / totalCount) * 100);
				runTask();
			}
			errorMsg = null;
		}
		
		private function runTask():void
		{
			if(taskList.length > 1){
				execProcess(taskList.shift());
			}else if(taskList.length > 0){
				setTimeout(execProcess, 500, taskList.shift());
			}else{
				trace("complete2");
			}
		}
		
		private var fileDict:Object = {};
		private var sysList:Array = [];
		private var objList:Array = [];
		
		private function printFiles(file:File, rootDir:File):void
		{
			switch(file.extension.toLowerCase()){
				case "cpp":
				case "c":
				case "s":
					break;
				default:
					return;
			}
			if(fileDict[file.nativePath]){
				return;
			}
			fileDict[file.nativePath] = true;
			var info:NativeProcessStartupInfo = createInfo();
			taskList.push(info);
			var path:String = rootDir.getRelativePath(file) + ".o";
			var destFile:File = workDir.resolvePath(path).parent;
			if(!destFile.exists){
				destFile.createDirectory();
			}
			compile(info, file, path);
			if(isSysLib(rootDir)){
				sysList.push(path);
			}else{
				objList.push(path);
			}
		}
		
		private function isSysLib(file:File):Boolean
		{
			if(file.nativePath.indexOf("makeblock") >= 0){
				return false;
			}
			if(file.nativePath.indexOf("SoftwareSerial") >= 0){
				return false;
			}
			if(file.nativePath.indexOf("Servo") >= 0){
				return false;
			}
			if(file.nativePath.indexOf("Wire") >= 0){
				return false;
			}
			return true;
		}
		
		private function compile(info:NativeProcessStartupInfo, source:File, output:String):void
		{
			var isCpp:Boolean = false;
			var isAsm:Boolean = false;
			switch(source.extension.toLowerCase()){
				case "cpp":
				case "ino":
					info.executable = bin.resolvePath("avr-g++.exe");
					isCpp = true;
					break;
				case "s":
					isAsm = true;
					//fall through
				case "c":
					info.executable = bin.resolvePath("avr-gcc.exe");
					break;
			}
			var argList:Vector.<String> = new Vector.<String>();
			
			argList.push("-c");
			argList.push("-g");
			if(!isAsm){
				argList.push("-Os");
				argList.push("-w");
			}
			if(isCpp){
				argList.push("-fno-exceptions");
				argList.push("-fno-threadsafe-statics");
			}
			if(isAsm){
				argList.push("-x");
				argList.push("assembler-with-cpp");
			}else{
				argList.push("-ffunction-sections");
				argList.push("-fdata-sections");
				argList.push("-MMD");
			}
			argList.push("-mmcu="+boardInfo.partno);
			argList.push("-DF_CPU=16000000L");
			argList.push("-DARDUINO=10605");
			argList.push("-DARDUINO_ARCH_AVR");
			boardInfo.getCompileArgList(argList);
			
			for each(var path:File in libList){
				argList.push("-I", path.nativePath);
			}
			
			argList.push(source.nativePath);
			argList.push("-o");
			argList.push(output);
			
			info.arguments = argList;
		}
		
		private function genLink():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avr-ar.exe");
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("rcs");
			argList.push("core.a");
			for each(var path:String in sysList){
				argList.push(path);
			}
			
			return info;
		}
		
		private function genElf():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avr-gcc.exe");
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("-w");
			argList.push("-Os");
			argList.push("-Wl,--gc-sections");
			argList.push("-mmcu=" + boardInfo.partno);
			argList.push("-o");
			argList.push(elf);
			for each(var obj:String in objList){
				argList.push(obj);
			}
			argList.push("core.a");
			argList.push("-L", "./");
			argList.push("-lm");
			return info;
		}
		
		private function copyObj():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avr-objcopy.exe");
			
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("-O");
			argList.push("ihex");
			argList.push("-j");
			argList.push(".eeprom");
			argList.push("--set-section-flags=.eeprom=alloc,load");
			argList.push("--no-change-warnings");
			argList.push("--change-section-lma");
			argList.push(".eeprom=0");
			argList.push(elf);
			argList.push(eep);
			
			return info;
		}
		
		private function copyHex():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avr-objcopy.exe");
			
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("-O");
			argList.push("ihex");
			argList.push("-R");
			argList.push(".eeprom");
			argList.push(elf);
			argList.push(hex);
			
			return info;
		}
		
		private function upload(port:String):NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avrdude.exe");
			
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("-C");
			argList.push(bin.resolvePath("../etc/avrdude.conf").nativePath);
			argList.push("-v");
			argList.push("-p");
			argList.push(boardInfo.partno);
			argList.push("-c");
			argList.push(boardInfo.programmer);
			argList.push("-P");
			argList.push(port);
			argList.push("-b");
			argList.push(boardInfo.baudrate.toString());
			argList.push("-D");
			argList.push("-U");
			argList.push("flash:w:"+hex+":i");
			
			return info;
		}
		
		private function createInfo():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.workingDirectory = workDir;
			return info;
		}
		
		private function execProcess(info:NativeProcessStartupInfo):void
		{
			var process:NativeProcess = new NativeProcess();
			process.addEventListener(NativeProcessExitEvent.EXIT, __onExit);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, __onError);
			process.start(info);
			printProcessInfo(info);
		}
		
		private function __onError(evt:ProgressEvent):void
		{
			var process:NativeProcess = evt.target as NativeProcess;
			var input:IDataInput = process.standardError;
			var msg:String = input.readMultiByte(input.bytesAvailable, "ascii");
			if(null == errorMsg){
				errorMsg = msg;
			}else{
				errorMsg += msg;
			}
		}
		
		static private function printProcessInfo(info:NativeProcessStartupInfo):void
		{
//			trace(info.executable.nativePath);
//			trace(info.arguments.join(" "));
		}
	}
}