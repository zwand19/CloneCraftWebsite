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
					
					return Helpers.promisedError new Error 'cannot continue for human turn'
				emitStatusOrRunTurn showFog, true

			socket.on 'create game', (data) ->
				checkRunningTournament()
				try
					if (data.teams[0].type is 'king' or data.teams[1].type is 'king') and Standings.getKingApi() is ''
						return socket.emit 'no king'
					createGame data.teams, socketWrapper, data.authToken
					
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
				else if (continuing or socketWrapper.gameHasHuman) and currentTeam.type is 'hosted'
					if !currentTeam.api_url
						Mongo.getCompetitor({name: currentTeam.username}, {api_url: true})
						.then (competitor) ->
							if (!competitor)
								
								socket.emit 'game destroyed'
								return
							
							socketWrapper.game.currentTeam.api_url = competitor.api_url
							runHostedTurn(showFog, competitor.api_url)
						.catch (err) ->
							Logger.error "Could not get hosted ai api url for #{currentTeam.username}"
							Logger.error err
							turnOver showFog
					else runHostedTurn showFog, currentTeam.api_url
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

			runHostedTurn = (showFog, api_url) ->
				json = socketWrapper.game.getGameStatus true
				url = "#{api_url}/api/turn"
				
				options =
					json: json
					url: url
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
			if team.type is "hosted"
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