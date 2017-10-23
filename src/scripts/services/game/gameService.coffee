class GameService
	constructor: (socket) ->
		@socket = socket

	#---------------
	# Public Methods
	#---------------
	attack: (minionId, selectedObject, currentTeam, showFog) ->
		attackX = selectedObject.x
		attackY = selectedObject.y
		
		#if we are attacking an object with size, find minion and attack the cell closest to it
		if selectedObject.si isnt undefined
			for minion in currentTeam.minions
				if minion.id is minionId
					base = selectedObject
					attackX = minion.x
					attackX = base.x if minion.x < base.x
					attackX = base.x + base.si - 1 if minion.x >= base.x + base.si
					attackY = minion.y
					attackY = base.y if minion.y < base.y
					attackY = base.y + base.si - 1 if minion.y >= base.y + base.si

		command =
			commandName: 'attack'
			minionId: minionId
			params:
				x: attackX
				y: attackY
		@socket.emit 'execute command',
			command: command
			showFog: showFog

	buildMinion: (x, y, stats, showFog) ->
		commandName = 'build lesser'
		commandName = 'build greater' if stats.d + stats.r + stats.h + stats.m + stats.s + stats.v > 10
		command =
			commandName: commandName
			minionId: null
			params:
				x: x
				y: y
				stats:
					d: stats.d
					r: stats.r
					h: stats.h
					m: stats.m
					s: stats.s
					v: stats.v
		@socket.emit 'execute command',
			command: command
			showFog: showFog

	handOff: (minionId, selectedObject, showFog) ->
		command =
			commandName: 'hand off'
			minionId: minionId
			params:
				minionId: selectedObject.id
		@socket.emit 'execute command',
			command: command
			showFog: showFog

	mine: (minionId, selectedObject, showFog) ->
		command =
			commandName: 'mine'
			minionId: minionId
			params:
				x: selectedObject.x
				y: selectedObject.y
		@socket.emit 'execute command',
			command: command
			showFog: showFog

	moveMinion: (direction, selectedObject, showFog) ->
		command =
			commandName: 'move'
			minionId: selectedObject.id
			params:
				direction: direction
		@socket.emit 'execute command',
			command: command
			showFog: showFog

	pingAIs: (ports, aisNotReadyFunction, aisReadyFunction) ->
		numToCheck = ports.length

		aiPinged = ->
			numToCheck--
			if numToCheck is 0 then aisReadyFunction()

		for port in ports
			address = "http://localhost:#{port}/api/heartbeat"
			aiNotPinged = ->
				aisNotReadyFunction address
				
			makeCorsRequest address, 'GET', null, aiNotPinged, aiPinged

	postToAI: (address, status, errorCallback, successCallback) ->
		makeCorsRequest address, 'POST', status, errorCallback, successCallback

	#----------------
	# Private Methods
	#----------------
	# Create the XHR object.
	createCORSRequest = (method, url) ->
		xhr = new XMLHttpRequest()
		if "withCredentials" of xhr
			# XHR for Chrome/Firefox/Opera/Safari.
			xhr.open method, url, true
		else if typeof XDomainRequest != "undefined"
			# XDomainRequest for IE.
			xhr = new XDomainRequest()
			xhr.open method, url
		else
			# CORS not supported.
			xhr = null
		xhr

	# Make the actual CORS request.
	makeCorsRequest = (url, method, data, errorCallback, successCallback) ->
		xhr = createCORSRequest method, url
		if !xhr
			alert 'Cannot make CORS requests to your AI using this browser, please try a different browser.'

		# Response handlers.
		xhr.onload = ->
			successCallback xhr.responseText
		xhr.onerror = ->
			errorCallback()

		if data
			xhr.send JSON.stringify data
		else xhr.send()
			
angular.module('app').service 'gameService', ['socket', GameService]