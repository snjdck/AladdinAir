"use strict";

const mime = require("mime");
const http = require("http");
const fs = require("fs");
const path = require("path");
const url = require("url");

const DOC_ROOT = "E:/test/bin-debug";
const PORT = 8888;

http.createServer(function(request, response){
	console.log(request.url);
	const extName = path.extname(request.url).slice(1);
	const pathname = url.parse(request.url).pathname;
	const filePath = DOC_ROOT + pathname;
	fs.readFile(filePath, function(err, data){
		if(err != null){
			response.statusCode = 404;
		}else{
			response.setHeader('Content-Type', findContentType(extName));
			response.setHeader('Content-Length', data.length);
			response.write(data);
		}
		response.end();
	});
}).listen(PORT);

function findContentType(extName){
	return (extName in mime) ? mime[extName] : "unknow";
}
