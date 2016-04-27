function loadXMLDoc(url, callback){
	var xmlhttp = new XMLHttpRequest();
	xmlhttp.onreadystatechange = function(){
		if(xmlhttp.readyState != 4){
			return;
		}
		if(callback != null){
			callback(xmlhttp.status == 200, xmlhttp.responseText);
		}
	};
	xmlhttp.open("GET", url, true);
	xmlhttp.send();
}