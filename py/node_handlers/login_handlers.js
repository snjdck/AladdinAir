"use strict";

exports.onRegister = function(packet){
	createPacket("client_register_reply", {result:true}).forward(packet);
};

exports.onLogin = function(packet){
	if(false){
		createPacket("client_login_notify").sendTo("logic", packet.usrId);
	}else{
		createPacket("client_login_reply", {result:true}).forward(packet);
	}
};

exports.onCheckNameValid = function(packet){
	createPacket("client_check_name_valid_reply", {result:true}).forward(packet);
};
