Constants = require '../../server/settings/constants'
Game = require '../../server/game/game'
Helpers = require '../../server/helpers'
HttpClient = require '../../server/utilities/httpClient'
Logger = require '../../server/utilities/logger'
TestHelpers = require '../testHelpers'
SocketIO = require 'socket.io'
SocketIOCommunication = require '../../server/socketIOCommunication'

describe 'SocketIOCommunication', ->
	#----------
	# Test data
	#----------
	command =
		command: 'build'

	commands = [
			commandName: Constants.commands.moveMinion
			minionId: '1'
			params:
				direction: 'S'
		,
			commandName: Constants.commands.moveMinion
			minionId: '2'
			params:
				direction: 'N'
	]

	teams = [
			id: '1'
			name: 'team 1'
			type: 'human'
		,
			id: '2'
			name: 'team 2'
			type: 'human'
	]

	#--------
	# Helpers
	#--------
	# Will set this to the function allowing us to create sockets
	connectSocket = null

	# Create a new socket and call the create game event on it
	connectNewSocket = (socket) ->
		socket = new Socket() if not socket
		connectSocket socket
		socket.functions['create game']
			teams: teams
			showFog: true
		socket

	# Connect multiple sockets
	connectSockets = (numSockets) ->
		connectNewSocket() for i in [0...numSockets]

	# Check that a given date is within half a minute of now
	expectDateIsNow = (date) ->
		expect(Helpers.getAgeInMinutes(date)).toBe 0

	# Takes in an array of booleans and checks against it to see if the games are null in the socketWrappers
	expectGamesToBeNull = (nullGames) ->
		for gameIsNull, i in nullGames
			if gameIsNull
				expect(SocketIOCommunication.socketWrappers[i].game).toBeNull()
			else expect(SocketIOCommunication.socketWrappers[i].game).not.toBeNull()

	# Checks the number of socketWrappers in memory
	expectNumSocketsToBe = (n) ->
		expect(SocketIOCommunication.socketWrappers.length).toBe n

	# Sets the last update of a socket wrapper to an old date so it will be garbage collected
	setOldUpdate = (wrapper) ->
		wrapper.lastUpdate = new Date("04/04/2000")

	# Connects a new socket with a function to call if that socket emits a certain event
	socketEmitFunction = (eventName, f) ->
		socket = new Socket()
		emittedFailedCommand = false
		socket.emit = (emittedEvent, data) ->
			if emittedEvent is eventName then f data
		connectNewSocket socket
		socket

	#------
	# Mocks
	#------
	# Mock our game object so we can overwrite some methods
	class MockGame
		constructor: (id, teams) ->
			if teams.length isnt 2 then throw new Error()
			@calledTurnOver = false
			@currentTeam =
				address: ''
				type: 'king'

		# mock execute command returns true if a command was passed in
		executeCommand: (command) ->
			if command then return true else return false

		executeCommands: (commands) ->
			[]

		getGameStatus: (fog) ->
			{ fog: fog }

		isOver: ->
			false

		turnOver: ->
			@calledTurnOver = true

	# Mock the socket object that we pass into our connect function
	class Socket
		constructor: ->
			@functions = {}
			@id = '1'
		emit: (eventName, data) ->
		# Store our event handlers
		on: (eventName, f) =>
			@functions[eventName] = f

	# Mock the socketIO library and capture the connect function where we put all of our socket logic
	socketIO =
		set: (param) ->
		sockets:
			on: (eventName, f) ->
				connectSocket = f

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(SocketIO, 'listen').andReturn socketIO
		spyOn(HttpClient, 'post').andCallFake TestHelpers.promisedData commands
		setInterval = ->
		Game.Game = MockGame
		SocketIOCommunication.setup({})

	#-----------
	# Unit Tests
	#-----------
	describe 'test setup', ->
		describe 'connectNewSocket', ->
			it 'should emit game created', ->
				# This is really testing the createGame function for completion
				emittedGameCreated = false
				socket = socketEmitFunction 'game created', ->
					emittedGameCreated = true
				expect(emittedGameCreated).toBeTruthy()

			it 'should emit game not created on bad data', ->
				emittedGameNotCreated = false
				socket = new Socket()
				socket.emit = (eventName) ->
					if eventName is 'game not created' then emittedGameNotCreated = true
				connectSocket socket
				socket.functions['create game']
					teams: 'GARBAGE TEAMS'
					showFog: true
				expect(emittedGameNotCreated).toBeTruthy()

			it 'should set socketWrapper game and lastUpdate', ->
				connectNewSocket()
				wrapper = SocketIOCommunication.socketWrappers[0]
				expect(wrapper.game).not.toBeNull()
				expect(wrapper.lastUpdate).not.toBeNull()
				# Test that the lastUpdate date is set to now
				expectDateIsNow wrapper.lastUpdate

	describe 'garbageCollect', ->
		it 'runs fine if no sockets in memory', ->
			try
				SocketIOCommunication.garbageCollect()
			catch
				TestHelpers.fail()

		it 'doesnt destroy a new game', ->
			connectNewSocket()
			expectGamesToBeNull [false]
			SocketIOCommunication.garbageCollect()
			expectGamesToBeNull [false]

		it 'doesnt destroy new games', ->
			connectSockets 4
			expectGamesToBeNull [false, false, false, false]
			SocketIOCommunication.garbageCollect()
			expectGamesToBeNull [false, false, false, false]

		it 'destroys an unplayed game', ->
			connectSockets 4
			setOldUpdate SocketIOCommunication.socketWrappers[2]
			SocketIOCommunication.garbageCollect()
			expectGamesToBeNull [false, false, true, false]

		it 'destroys multiple unplayed games', ->
			connectSockets 4
			setOldUpdate SocketIOCommunication.socketWrappers[0]
			setOldUpdate SocketIOCommunication.socketWrappers[2]
			SocketIOCommunication.garbageCollect()
			expectGamesToBeNull [true, false, true, false]

	describe 'socket events', ->
		describe 'continue', ->
			it 'should emit game destroyed if game is null', (done) ->
				socket = connectNewSocket()
				emittedGameDestroyed = false
				socket.emit = (eventName) ->
					if eventName is 'game destroyed' then emittedGameDestroyed = true
				SocketIOCommunication.socketWrappers[0].game = null
				socket.functions['continue'](true)
				.finally ->
					expect(emittedGameDestroyed).toBeTruthy()
					done()

			it 'should set a new lastUpdate', (done) ->
				socket = connectNewSocket()
				setOldUpdate SocketIOCommunication.socketWrappers[0]
				socket.functions['continue'](true)
				.finally ->
					expectDateIsNow SocketIOCommunication.socketWrappers[0].lastUpdate
					done()

			it 'should emit a game status', (done) ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['continue'](true)
				.finally ->
					expect(status).not.toBeNull()
					expect(status.fog).toBeTruthy
					done()

			it 'should emit status with correct fog', (done) ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['continue'](false)
				.finally ->
					expect(status).not.toBeNull()
					expect(status.fog).toBeFalsy()
					done()

			it 'should handle king api errors', (done) ->
				HttpClient.post.andCallFake(TestHelpers.promiseError)
				status = null
				calledTurnOver = false
				socket = socketEmitFunction 'status', (data) ->
					status = data
				SocketIOCommunication.socketWrappers[0].game.turnOver = ->
					calledTurnOver = true
				socket.functions['continue'](true)
				.finally ->
					expect(status).not.toBeNull()
					expect(calledTurnOver).toBeTruthy()
					done()

		describe 'disconnect', ->
			it 'should remove only socket', ->
				socket = connectNewSocket()
				expectNumSocketsToBe 1
				socket.functions['disconnect']()
				expectNumSocketsToBe 0

			it 'should remove socket from list', ->
				connectSockets 4
				socket = connectNewSocket()
				connectSockets 4
				expectNumSocketsToBe 9
				socket.functions['disconnect']()
				expectNumSocketsToBe 8

		describe 'end game', ->
			it 'should set game and last update to null', ->
				socket = connectNewSocket()
				wrapper = SocketIOCommunication.socketWrappers[0]
				expect(wrapper.game).not.toBeNull()
				expect(wrapper.lastUpdate).not.toBeNull()
				socket.functions['end game']()
				expect(wrapper.game).toBeNull()
				expect(wrapper.lastUpdate).toBeNull()

		describe 'execute command', ->
			it 'should set a new lastUpdate', ->
				socket = connectNewSocket()
				setOldUpdate SocketIOCommunication.socketWrappers[0]
				socket.functions['execute command']
					showFog: true
					command: command
				expectDateIsNow SocketIOCommunication.socketWrappers[0].lastUpdate

			it 'should emit failed command on failure', ->
				emittedFailedCommand = false
				socket = socketEmitFunction 'failed command', ->
					emittedFailedCommand = true
				socket.functions['execute command']
					showFog: true
					command: undefined
				expect(emittedFailedCommand).toBeTruthy()

			it 'should emit a game status on success', ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['execute command']
					showFog: true
					command: command
				expect(status).not.toBeNull()
				expect(status.fog).toBeTruthy()

			it 'should emit status with correct fog', ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['execute command']
					showFog: false
					command: command
				expect(status).not.toBeNull()
				expect(status.fog).toBeFalsy()

		describe 'get status', ->
			it 'should set a new lastUpdate', ->
				socket = connectNewSocket()
				setOldUpdate SocketIOCommunication.socketWrappers[0]
				socket.functions['get status'] true
				expectDateIsNow SocketIOCommunication.socketWrappers[0].lastUpdate

			it 'should emit a game status', ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['get status'] true
				expect(status).not.toBeNull()
				expect(status.fog).toBeTruthy()

			it 'should emit status with correct fog', ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['get status'] false
				expect(status).not.toBeNull()
				expect(status.fog).toBeFalsy()

		describe 'turn over', ->
			it 'should set a new lastUpdate', ->
				socket = connectNewSocket()
				setOldUpdate SocketIOCommunication.socketWrappers[0]
				socket.functions['turn over'] true
				expectDateIsNow SocketIOCommunication.socketWrappers[0].lastUpdate

			it 'should emit a game status', ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['turn over'] true
				expect(status).not.toBeNull()
				expect(status.fog).toBeTruthy()

			it 'should emit status with correct fog', ->
				status = null
				socket = socketEmitFunction 'status', (data) ->
					status = data
				socket.functions['turn over'] false
				expect(status).not.toBeNull()
				expect(status.fog).toBeFalsy()

			it 'should call turnOver on the game', ->
				socket = connectNewSocket()
				expect(SocketIOCommunication.socketWrappers[0].game.calledTurnOver).toBeFalsy()
				socket.functions['turn over'] true
				expect(SocketIOCommunication.socketWrappers[0].game.calledTurnOver).toBeTruthy()