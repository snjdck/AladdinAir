"use strict";

exports.onTest = function(packet){
	console.log("test db");
	var collection = db.collection('cats');
	collection.find({}).toArray(function(err, docs) {
		//assert.equal(err, null);
		//assert.equal(2, docs.length);
		console.log("Found the following records");
		console.dir(docs);
	});
};
