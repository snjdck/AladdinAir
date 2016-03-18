"use strict";

const mime = require("mime");
const http = require("http");
const fs = require("fs");
const path = require("path");
const url = require("url");

var docRoot = "E:/test/bin-debug";
docRoot = "D:/Program Files (x86)/Apache Software Foundation/Apache2.2/htdocs"

const server = new http.Server();
server.listen(8888);

server.on("request", function(request, response){
	console.log(request.url);
	var ext = path.extname(request.url).slice(1);
	console.log(ext);
	var ContentType = "text/html";
	if(ext in mime){
		ContentType = mime[ext];
	}
	const pathname = url.parse(request.url).pathname;
	const filePath = docRoot + pathname;
	fs.readFile(filePath, function(err, data){
		if(err != null){
			response.endWithError(404);
			return;
		}
		response.setHeader('Content-Type', ContentType);
		response.setHeader('Content-Length', data.length);
		response.statusCode = 200;
		response.end(data);
	});
});

http.ServerResponse.prototype.endWithError = function(errorCode){
	this.statusCode = errorCode;
	this.end();
}