Board = require '../entities/board'
CommandParser = require './commandParser'
GameRules = require '../settings/gameRules'
GameStatus = require './gameStatus'
Helpers = require '../helpers'
Logger = require '../utilities/logger'
Team = require '../entities/team'

# Creates the game board and contains method to run the games based off of inputted commands
class Game
	constructor: (@id, @teams, startingConfiguration) ->
		if @teams.length isnt 2 or not @teams[0] or not @teams[1] or @teams[0] not instanceof Team or @teams[1] not instanceof Team
			Logger.error 'Cannot create game with invalid teams'
			throw new Error 'Unable to create game. Invalid teams'
		@turn = 0
		@currentTeam = @teams[0]
		@round = 1
		@numTeamsRemaining = @teams.length

		@zipPath = null
		@makeBoard startingConfiguration
		@resourceString = "" # starting resource string used to recreate game
		for resource in @board.resources
			@resourceString += "#{resource.x}.#{resource.y}."

	#---------------
	# Public Methods
	#---------------
	# parses and executes a single command
	executeCommand: (command) ->
		parser = new CommandParser @currentTeam, @board
		return parser.parse command

	# takes in a list of commands and passes them to the parser
	# checks if game is over and sets the turn to the next player up
	# returns all successful commands
	executeCommands: (commands) ->
		parser = new CommandParser(@currentTeam, @board)
		successfulCommands = []
		if commands and commands.length
			for command in commands
				try
					if parser.parse command then successfulCommands.push command
		@turnOver()
		return successfulCommands
	
	# returns the info of the game necessary to recreate it
	getGameInfo: () ->
		info =
			resources: @resourceString
			team1name: @teams[0].name
			team2name: @teams[1].name
		return info

	# gets the status of the game for the client
	getGameStatus: (showFog) ->
		return new GameStatus(@currentTeam, this, true) if showFog is undefined
		return new GameStatus @currentTeam, this, showFog

	# assumes there are only two teams in the game
	getLoser: () ->
		return null if @getWinner() is null
		return @teams[0] if @getWinner() is @teams[1]
		return @teams[1]

	# returns the winner of the game
	# tiebreaker: health left on base, gold mined, second team
	getWinner: () ->
		return @teams[0] if @teams[1].base is null
		return @teams[1] if @teams[0].base is null
		return @teams[0] if @teams[0].base.health > @teams[1].base.health
		return @teams[1] if @teams[1].base.health > @teams[0].base.health
		return @teams[0] if @teams[0].goldMined > @teams[1].goldMined
		return @teams[1] if @teams[1].goldMined > @teams[0].goldMined
		return @teams[1]

	# sets the new team who is up and posts the status of the game to them
	incrementTurn: () ->
		@turn++
		if @turn is @teams.length
			@turn = 0
			@round++
		@currentTeam = @teams[@turn]

		if @currentTeam.base is null
			@incrementTurn()
			return

	# returns true if the game is over
	isOver: () ->
		numTeamsRemaining = 0
		for team in @teams
			numTeamsRemaining++ if team.base isnt null
		return numTeamsRemaining is 1 or @round > GameRules.maxRounds

	# creates the static one vs one board
	# this board is wider than it is long with a base at the east and west ends
	makeBoard: (startingConfiguration) ->
		placeResources = ->
			for resource in startingConfiguration.resources
				@board.placeResource resource.x, resource.y
		switch GameRules.map
			when 'square'
				squareConstants = GameRules.maps.square
				# make board
				boardSize = squareConstants.quadrantSize * 2
				@board = new Board 1, boardSize, boardSize
				# place bases
				baseCoords = [
						x: squareConstants.sideBuffer
						y: squareConstants.sideBuffer
					,
						x: boardSize - squareConstants.sideBuffer - 2
						y: squareConstants.sideBuffer
					,
						x: boardSize - squareConstants.sideBuffer - 2
						y: boardSize - squareConstants.sideBuffer - 2
					,
						x: squareConstants.sideBuffer
						y: boardSize - squareConstants.sideBuffer - 2
				]
				base1Coord = Helpers.randomElement baseCoords
				while not base2Coord or base1Coord is base2Coord
					base2Coord = Helpers.randomElement baseCoords
				placeBases @board, @teams, base1Coord, base2Coord
				# place resources
				if not startingConfiguration
					for i in [0...squareConstants.resourcesPerQuadrant]
						placed = false
						while not placed
							resourceX = Math.floor Math.random() * @board.width / 2
							resourceY = Math.floor Math.random() * @board.height / 2
							xDistanceFromCenter = @board.width / 2 - resourceX
							yDistanceFromCenter = @board.height / 2 - resourceY
							resourceCoords = [
									x: resourceX
									y: resourceY
								,
									x: resourceX + xDistanceFromCenter * 2
									y: resourceY
								,
									x: resourceX + xDistanceFromCenter * 2
									y: resourceY + yDistanceFromCenter * 2
								,
									x: resourceX
									y: resourceY + yDistanceFromCenter * 2
							]
							placed = @board.placeResources resourceCoords
				else placeResources()
			when 'standard'
				standardConstants = GameRules.maps.standard
				# make board
				boardWidth = 2 * standardConstants.sideBuffer + 2 * GameRules.base.size + standardConstants.distanceBetweenBases
				@board = new Board 1, boardWidth, standardConstants.height
				# place bases
				coord1 =
					x: standardConstants.sideBuffer
					y: Math.round standardConstants.height / 2 - GameRules.base.size / 2
				coord2 =
					x: standardConstants.sideBuffer + standardConstants.distanceBetweenBases + GameRules.base.size
					y: Math.round standardConstants.height / 2 - GameRules.base.size / 2
				placeBases @board, @teams, coord1, coord2
				# place resources
				if not startingConfiguration
					for i in [0...standardConstants.resourcesPerTeam]
						placed = false
						while not placed
							resourceX = Math.floor Math.random() * (@board.width - 1) / 2
							resourceY = Math.floor Math.random() * @board.height
							placed = @board.placeResource resourceX, resourceY
						distanceFromCenter = (@board.width - 1) / 2 - resourceX
						@board.placeResource resourceX + distanceFromCenter * 2, resourceY
				else placeResources()
			else throw new Error 'Unable to create game. Invalid map'

	# tells the team that their turn is over and increments the current team
	turnOver: () ->
		@currentTeam.turnOver()

		@numTeamsRemaining = 0
		for team in @teams
			@numTeamsRemaining++ if team.base isnt null

		return if @numTeamsRemaining is 1
		@incrementTurn()

	#----------------
	# Private Methods
	#----------------
	placeBases = (board, teams, coord1, coord2) ->
		placed1 = board.placeBase teams[0], coord1.x, coord1.y
		placed2 = board.placeBase teams[1], coord2.x, coord2.y
		if not placed1 or not placed2
			Logger.error 'Could not place base for new game'
			throw new Error 'Unable to place game bases'

# Not exporting the class directly so that we can mock it out if we need to
module.exports =
	Game: Game