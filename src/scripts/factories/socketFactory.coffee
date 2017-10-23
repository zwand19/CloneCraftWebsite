SocketFactory = ($rootScope) ->
	socket = io()
	return {
		on: (eventName, callback) ->
			socket.on eventName, ->
				args = arguments
				callback.apply socket, args
		emit: (eventName, data, callback) ->
			socket.emit eventName, data, ->
			args = arguments
			if callback then callback.apply socket, args
	}

angular.module('app').factory 'socket', ['$rootScope', SocketFactory]