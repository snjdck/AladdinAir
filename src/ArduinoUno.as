package
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileIO2;
	import flash.utils.IDataInput;
	
	public class ArduinoUno extends Sprite
	{
		private var sdk:File = new File("C:/Program Files (x86)/Arduino");
		private var bin:File = sdk.resolvePath("hardware/tools/avr/bin");
		
		private var libList:Array = [];
		private var taskList:Array = [];
		private var linkList:Array = [];
		private var workDir:File = File.desktopDirectory.resolvePath("test");
		
		private var elf:String = "project.elf";
		private var eep:String = "project.eep";
		private var hex:String = "project.hex";
		
		private var errorMsg:String;
		
		public function ArduinoUno()
		{
			libList.push(sdk.resolvePath("hardware/arduino/avr/cores/arduino"));
			libList.push(sdk.resolvePath("hardware/arduino/avr/variants/standard"));
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
			compile(info, File.desktopDirectory.resolvePath("project_9_6.cpp"), "project.cpp.o");
			taskList.unshift(info);
			objList.unshift("project.cpp.o");
			
			for each(var path:String in sysList){
				linkList.push(genLink(path));
			}
			linkList.push(genElf());
			linkList.push(copyObj());
			linkList.push(copyHex());
			linkList.push(upload());
			
			for each(var task:NativeProcessStartupInfo in taskList){
				var process:NativeProcess = new NativeProcess();
				process.addEventListener(NativeProcessExitEvent.EXIT, __onExit);
				process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, __onError);
				process.start(task);
			}
		}
		
		private function createInfo():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			info.workingDirectory = workDir;
			return info;
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
		
		private var successCount:int = 0;
		
		private function __onExit2(evt:NativeProcessExitEvent):void
		{
			if(evt.exitCode > 0){
				trace(evt.exitCode, errorMsg);
			}
			runTask();
			errorMsg = null;
		}
		private function runTask():void
		{
			if(linkList.length <= 0){
				trace("complete2");
				return;
			}
			var task:NativeProcessStartupInfo = linkList.shift();
			var process:NativeProcess = new NativeProcess();
			process.addEventListener(NativeProcessExitEvent.EXIT, __onExit2);
			process.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, __onError);
			process.start(task);
			trace(task.executable.nativePath);
			trace(task.arguments.join(" "));
		}
		
		private function __onExit(evt:NativeProcessExitEvent):void
		{
			if(evt.exitCode > 0){
				trace(evt.exitCode, errorMsg);
			}
			if(++successCount >= taskList.length){
				trace("complete1");
				runTask();
			}
			errorMsg = null;
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
					info.executable = bin.resolvePath("avr-gcc.exe");
					isAsm = true;
					break;
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
			argList.push("-mmcu=atmega328p");
			argList.push("-DF_CPU=16000000L");
			argList.push("-DARDUINO=10605");
			argList.push("-DARDUINO_AVR_UNO");
			argList.push("-DARDUINO_ARCH_AVR");
			
			for each(var path:File in libList){
				argList.push("-I", path.nativePath);
			}
			
			argList.push(source.nativePath);
			argList.push("-o");
			argList.push(output);
			
			info.arguments = argList;
		}
		
		private function genLink(objPath:String):NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avr-ar.exe");
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("rcs");
			argList.push("core.a");
			argList.push(objPath);
			
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
			argList.push("-mmcu=atmega328p");
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
		
		private function upload():NativeProcessStartupInfo
		{
			var info:NativeProcessStartupInfo = createInfo();
			info.executable = bin.resolvePath("avrdude.exe");
			
			var argList:Vector.<String> = new Vector.<String>();
			info.arguments = argList;
			
			argList.push("-C");
			argList.push(bin.resolvePath("../etc/avrdude.conf").nativePath);
			argList.push("-v");
			argList.push("-patmega328p");
			argList.push("-carduino"); 
			argList.push("-P");
			argList.push("COM4");
			argList.push("-b");
			argList.push("115200");
			argList.push("-D");
			argList.push("-U");
			argList.push("flash:w:"+hex+":i");
			
			return info;
		}
	}
}