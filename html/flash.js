var File = runtime.flash.filesystem.File;
var FileStream = runtime.flash.filesystem.FileStream;
var FileMode = runtime.flash.filesystem.FileMode;

function require(name)
{
	var file = File.applicationDirectory.resolvePath(name + ".js");
	var fs = new FileStream();
	fs.open(file, FileMode.READ);
	var content = fs.readUTFBytes(fs.bytesAvailable);
	fs.close();
	var module = {};
	var exports = {};
	module.exports = exports;
	eval("(function(exports, module){" + content + "})")(exports, module);
	return module.exports;
}