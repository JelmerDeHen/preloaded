'use strict';
rpc.exports = {
	init: function (stage, parameters) {
		var date=new Date();
		var msg = date.getHours() + ":" + date.getMinutes() + ": " + stage + " " + JSON.stringify(parameters) + "\n";
		return Socket.connect({"host":"172.17.0.1","port":1337}).then(function(SocketConnection){
			var pckt=[];
			for (var i=0; i!==msg.length; i++) pckt.push(msg.charCodeAt(i));
			return SocketConnection.output.writeAll(pckt).then(function(){ SocketConnection.close() });
		});
		resume();
	}
};
