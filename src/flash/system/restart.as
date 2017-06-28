package flash.system
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;

	public function restart():void
	{
		if(Capabilities.isDebugger){
			return;
		}
		var xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
		var ns:Namespace = xml.namespace();
		var filename:String = xml.ns::filename;
		
		if(isWindowsOS()){
			filename += ".exe";
		}else if(isMacOS()){
			filename = "../MacOS/" + filename;
		}else{
			return;
		}
		
		NativeApplication.nativeApplication.exit();
		var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		info.workingDirectory = File.applicationDirectory;
		info.executable = File.applicationDirectory.resolvePath(filename);
		new NativeProcess().start(info);
	}
}