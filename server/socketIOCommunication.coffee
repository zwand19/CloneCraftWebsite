Authentication = require './authentication'
Config = require './config.json'
Constants = require './settings/constants'
Game = require './game/game'
Helpers = require './helpers'
HttpClient = require './utilities/httpClient'
Logger = require './utilities/logger'
Mongo = require './utilities/mongoClient'
ServerStatus = require './serverStatus'
SocketIO = require 'socket.io'
Standings = require './standings/standings'
Team = require './entities/team'
UUID = require 'node-uuid'

# Runs all socket IO communication for the server
class SocketIOCommunication
	constructor: () ->
		@socketWrappers = []
		_this = @
		setInterval =>
			_this.garbageCollect.call _this
		, Config.socket_garbage_cleanup_interval

	#---------------
	# Public Methods
	#---------------
	garbageCollect: ->
		Logger.info "Cleaning up unused games..."
		len = @socketWrappers.length
		socketsRemoved = 0
		gamesInMemory = 0
		# loop through sockets in memory and clear game if not updated recently
		for socketWrapper in @socketWrappers
			if not socketWrapper.lastUpdate or not socketWrapper.lastUpdate
				socketWrapper.lastUpdate = null
				socketWrapper.game = null
				continue
			age = Helpers.getAgeInMinutes socketWrapper.lastUpdate
			if age > Config.minutes_to_hold_games_in_memory
				socketWrapper.game = null
				socketWrapper.socket.emit 'game destroyed'
				socketsRemoved++
			else gamesInMemory++
		# log cleanup info
		if socketsRemoved
			Logger.info "Done! Destroyed #{socketsRemoved} games. #{gamesInMemory} games still in memory. #{@socketWrappers.length} sockets connected."
		else Logger.info "Done! No games destroyed. #{gamesInMemory} games still in memory. #{@socketWrappers.length} sockets connected"

	setup: (server) ->
		@socketWrappers = []

		@io = SocketIO.listen(server)

		@io.sockets.on 'connection', (socket) =>
			socketWrapper =
				game: null
				gameHasHuman: null
				lastUpdate: null
				socket: socket

			@socketWrappers.push socketWrapper

			socket.emit 'connected'

			socket.on 'continue', (showFog) ->
				checkRunningTournament()
				if not socketWrapper.game
					socket.emit 'game destroyed'
					return Helpers.promisedError new Error()
				socketWrapper.lastUpdate = new Date()
				# Client should know not to send continue for human turn
				if socketWrapper.game.currentTeam.type is 'human'
					Logger.info 'socket continue called for human'
					return Helpers.promisedError new Error 'cannot continue for human turn'
				emitStatusOrRunTurn showFog, true

			socket.on 'create game', (data) ->
				checkRunningTournament()
				try
					if (data.teams[0].type is 'king' or data.teams[1].type is 'king') and Standings.getKingApi() is ''
						return socket.emit 'no king'
					Logger.info "creating game for socket id #{socket.id}", data.teams
					createGame data.teams, socketWrapper, data.authToken
					Logger.info "created game", socketWrapper.game
					socketWrapper.gameHasHuman = socketWrapper.game.teams[0].type is 'human' or socketWrapper.game.teams[1].type is 'human'
					if socketWrapper.gameHasHuman
						emitStatusOrRunTurn data.showFog, false
					else
						emitStatus data.showFog
				catch e
					Logger.error 'Error creating game'
					Logger.error e
					socket.emit 'game not created'

			socket.on 'disconnect', () =>
				# Remove the socket wrapper from memory
				for i in [0...@socketWrappers.length]
					socketWrapper = @socketWrappers.pop()
					if socketWrapper.socket is socket then return
					@socketWrappers.unshift socketWrapper

			socket.on 'end game', () ->
				Logger.info "ending game for socket id #{socket.id}"
				socketWrapper.game = null
				socketWrapper.lastUpdate = null

			socket.on 'execute command', (data) ->
				checkRunningTournament()
				gameUpdated()
				if socketWrapper.game.executeCommand data.command
					emitStatus data.showFog
				else socket.emit 'failed command'

			socket.on 'execute commands', (data) ->
				checkRunningTournament()
				gameUpdated()
				socketWrapper.game.executeCommands data.commands
				emitStatus data.showFog

			socket.on 'get status', (showFog) ->
				checkRunningTournament()
				gameUpdated()
				emitStatus showFog

			socket.on 'turn over', (showFog) ->
				checkRunningTournament()
				gameUpdated()
				socketWrapper.game.turnOver()
				emitStatusOrRunTurn showFog, false

			#---------------
			# Helper Methods
			#---------------
			checkRunningTournament = ->
				if ServerStatus.runningTournament
					socket.emit 'running tournament'
					throw new Error()

			emitRunAI = ->
				socket.emit 'get ai commands', socketWrapper.game.getGameStatus true

			emitStatus = (showFog) ->
				socket.emit 'status', socketWrapper.game.getGameStatus showFog

			emitStatusOrRunTurn = (showFog, continuing) ->
				currentTeam = socketWrapper.game.currentTeam
				if (continuing or socketWrapper.gameHasHuman) and currentTeam.type is 'king'
					runKingTurn showFog
				else if (continuing or socketWrapper.gameHasHuman) and currentTeam.type is 'ai'
					emitRunAI()
				else if (continuing or socketWrapper.gameHasHuman) and currentTeam.type is 'submitted'
					if currentTeam.address is ''
						Mongo.getCompetitor({name: currentTeam.username}, {address: true})
						.then (competitor) ->
							socketWrapper.game.currentTeam.address = competitor.address
							runSubmittedTurn(showFog, competitor.address)
						.catch (err) ->
							Logger.error "Could not get submitted ai address for #{currentTeam.username}"
							Logger.error err
							turnOver showFog
					else runSubmittedTurn showFog, currentTeam.address
				else emitStatus showFog

			gameUpdated = () ->
				if not socketWrapper.game
					socket.emit 'game destroyed'
					throw new Error()
				return if socketWrapper.game.isOver()
				socketWrapper.lastUpdate = new Date()

			runKingTurn = (showFog) ->
				options =
					json: socketWrapper.game.getGameStatus true
					url: Standings.getKingApi() + '/api/turn'
					timeout: Constants.tournament.requestTimeout
				HttpClient.post(options)
				.then (commands) ->
					socketWrapper.game.executeCommands commands
					emitStatus showFog
				.catch (err) ->
					Logger.log 'King of the hill API error'
					Logger.log err
					turnOver showFog

			runSubmittedTurn = (showFog, address) ->
				options =
					json: socketWrapper.game.getGameStatus true
					url: "#{address}/api/turn"
					timeout: Constants.tournament.requestTimeout
				HttpClient.post(options)
				.then (commands) ->
					socketWrapper.game.executeCommands commands
					emitStatus showFog
				.catch (err) ->
					Logger.log 'King of the hill API error'
					Logger.log err
					turnOver showFog

			turnOver = (showFog) ->
				socketWrapper.game.turnOver()
				emitStatus showFog

	#----------------
	# Private Methods
	#----------------
	createGame = (teams, socketWrapper, authToken) ->
		gameTeams = []
		# Create teams from client data
		for team, i in teams
			newTeam = new Team i, team.name, '', team.type
			if team.type is "submitted"
				try
					username = Authentication.authenticateToken authToken
				if not username
					return socket.emit 'unauthorized'
				newTeam.username = username
			gameTeams.push newTeam
		# Create our game from the teams and let the client know we finished
		socketWrapper.game = new Game.Game UUID.v1(), gameTeams
		socketWrapper.lastUpdate = new Date()
		socketWrapper.socket.emit 'game created'


module.exports = new SocketIOCommunication()