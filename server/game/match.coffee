Competitor = require './competitor'
Constants = require '../settings/constants'
EventBus = require '../eventBus'
FileManager = require './fileManager'
Game = require('./game').Game
HttpClient = require '../utilities/httpClient'
Logger = require '../utilities/logger'
Mongo = require '../utilities/mongoClient'
Team = require '../entities/team'
uuid = require 'node-uuid'
Q = require 'q'

# Manages posting to clients, receiving commands, setting up the board, and passing the commands to get executed
class Match
	#---------------
	# Public Methods
	#---------------
	constructor: (@tournamentId, @id, @competitor1, @competitor2, @bestOf, @roundRobin, @folderPath) ->
		@competitor1Wins = 0
		@competitor2Wins = 0
		@competitor1.startedMatch() if @competitor1 != null
		@competitor2.startedMatch() if @competitor2 != null
		@games = []
		@gameInfos = []
		@statuses = []
		for i in [0...@bestOf]
			team1 = new Team(@competitor1.id, @competitor1.name, @competitor1.apiUrl) if @competitor1 != null
			team2 = new Team(@competitor2.id, @competitor2.name, @competitor2.apiUrl) if @competitor2 != null
			if (i % 2) is 0
				@games.push new Game(uuid.v1(), [team1, team2])
			else @games.push new Game(uuid.v1(), [team2, team1])
			if @competitor1 != null and @competitor2 != null
				@gameInfos.push @games[i].getGameInfo()
			else @gameInfos.push null
			@statuses.push []
		@winner = null

	# called when a game is finished, starts a new game if the match is still underway
	gameOver: (game) ->
		winner = game.getWinner()
		winningCompetitor = null
		if (winner.id is @competitor1.id)
			@competitor1Wins++
			Logger.log "game winner: #{@competitor1.name}"
		else
			@competitor2Wins++
			Logger.log "game winner: #{@competitor2.name}"
		# get match winner
		if @competitor1Wins > @competitor2Wins
			winningCompetitor = @competitor1
		if @competitor2Wins > @competitor1Wins
			winningCompetitor = @competitor2
		# check if the match is over
		if @roundRobin
			done = @competitor1Wins + @competitor2Wins >= @bestOf
		else done = @competitor2Wins > @bestOf / 2 or @competitor1Wins > @bestOf / 2
		# post game results to AIs
		HttpClient.post
			json:
				won: winningCompetitor is @competitor1
				match_over: done
				id: game.id
			url: @competitor1.apiUrl + '/api/gameResults'
		HttpClient.post
			json:
				won: winningCompetitor is @competitor2
				match_over: done
				id: game.id
			url: @competitor2.apiUrl + '/api/gameResults'
		# either finish the match or start another game
		if done then @matchOver(winningCompetitor) else @startGame()

	# posts to the current team to get their commands, processes them when they come in
	getCommands: ->
		options =
			json: @game.getGameStatus true
			url: @game.currentTeam.apiUrl + '/api/turn'
			timeout: Constants.tournament.requestTimeout
		match = @
		failed = false
		HttpClient.post(options)
		.catch (err) ->
			# If we did not successfully ping the endpoint then end the teams turn without any commands
			failed = true
			Logger.logApiError err, match.game.currentTeam.apiUrl, match.game.getGameStatus true
		.then (commands) ->
			if failed then commands = []
			match.game.executeCommands commands
		.done ->
			# Push onto our match info
			match.statuses[match.getGameIndex()].push match.game.getGameStatus false
			# Check if game is over or continue game
			if match.game.isOver()
				sendTeamStatsToDb match.game.getWinner(), true
				sendTeamStatsToDb match.game.getLoser(), false
				if match.competitor1.name is match.game.teams[0].name
					updateCompetitorStats match.competitor1, match.game.teams[0]
					updateCompetitorStats match.competitor2, match.game.teams[1]
				else
					updateCompetitorStats match.competitor2, match.game.teams[0]
					updateCompetitorStats match.competitor1, match.game.teams[1]
				match.gameOver(match.game)
			else 
				match.getCommands()

	# gets the current index of game being played
	getGameIndex: ->
		return @competitor1Wins + @competitor2Wins

	# called when the match is finished, notifies the competitors and publishes the event
	# winner is null if BYE vs BYE
	# winner is null if Round Robin split the matches
	matchOver: (winner) ->
		@winner = winner
		@competitor1.finishedMatch() if @competitor1
		@competitor2.finishedMatch() if @competitor2
		# if competitor1 won
		if @competitor1 and @winner and @competitor1.name is @winner.name
			Logger.info "MATCH WINNER: #{@competitor1.name}"
			sendMatchStatsToDb @competitor1, 'win'
			if @competitor2 then sendMatchStatsToDb @competitor2, 'loss'
		# if competitor2 won
		else if @competitor2 and @winner and @competitor2.name is @winner.name
			Logger.info "MATCH WINNER: #{@competitor2.name}"
			sendMatchStatsToDb @competitor2, 'win'
			if @competitor1 then sendMatchStatsToDb @competitor1, 'loss'
		# if there was a draw
		else if @competitor1 and @competitor2
			Logger.info "MATCH TIED: #{@competitor1.name} vs. #{@competitor2.name}"
			sendMatchStatsToDb @competitor1, 'draw'
			sendMatchStatsToDb @competitor2, 'draw'
		# write match to file
		if @roundRobin
			@deferred.resolve FileManager.writeRoundRobinMatchToFile @
		else @deferred.resolve FileManager.writeBracketMatchToFile @

	# starts the next game in the list
	startGame: ->
		@game = @games[@getGameIndex()]
		if not @game
			Logger.error 'match not properly terminated'
			throw new Error 'match not properly terminated'
		Logger.info "starting game between #{@competitor1.name} and #{@competitor2.name}"
		# push initial game status
		@statuses[@getGameIndex()].push @game.getGameStatus false
		@getCommands()

	# kicks off the match
	start: ->
		@deferred = Q.defer()
		if not @competitor1
			process.nextTick ->
				@matchOver(@competitor2)
		else if not @competitor2
			process.nextTick ->
				@matchOver(@competitor1)
		else
			Logger.info "MATCH START: #{@competitor1.name} vs. #{@competitor2.name}"
			gameIds = []
			for game in @games
				gameIds.push game.id
			#post match info to AIs
			matchInfo1 =
				best_of: @bestOf
				game_ids: gameIds
				opponent_name: @competitor2.name
				tournament_id: @tournamentId
			matchInfo2 =
				best_of: @bestOf
				game_ids: gameIds
				opponent_name: @competitor1.name
				tournament_id: @tournamentId
			options1 =
				json: matchInfo1
				url: "#{@competitor1.apiUrl}/api/matchStart"
			options2 =
				json: matchInfo2
				url: "#{@competitor2.apiUrl}/api/matchStart"
			HttpClient.post options1
			HttpClient.post options2
			@startGame()
		@deferred.promise

	#----------------
	# Private Methods
	#----------------
	# Update competitor match record stats in database
	sendMatchStatsToDb = (competitor, result) ->
		if result is 'win'
			Mongo.findAndModifyCompetitor({ name: competitor.name }, {$inc:{match_wins: 1}})
		if result is 'loss'
			Mongo.findAndModifyCompetitor({ name: competitor.name }, {$inc:{match_losses: 1}})
		if result is 'draw'
			Mongo.findAndModifyCompetitor({ name: competitor.name }, {$inc:{match_draws: 1}})

	# Update competitor game-related stats such as minions built in database
	sendTeamStatsToDb = (team, isWinner) ->
		modification =
			$inc:
				minions_killed: team.stats.minionsKilled
				greater_minions_built: team.stats.greaterMinionsBuilt
				lesser_minions_built: team.stats.lesserMinionsBuilt
				foxes_built: team.stats.foxesBuilt
				tanks_built: team.stats.tanksBuilt
				grunts_built: team.stats.gruntsBuilt
				archers_built: team.stats.archersBuilt
				seers_built: team.stats.seersBuilt
				miners_built: team.stats.minersBuilt
				gold_mined: team.goldMined
		if isWinner then modification.$inc.game_wins = 1 else modification.$inc.game_losses = 1
		Mongo.findAndModifyCompetitor({ name: team.name }, modification)

	# Adds team stats to competitor
	updateCompetitorStats = (competitor, team) ->
		competitor.minionsKilled += team.stats.minionsKilled
		competitor.greaterMinionsBuilt += team.stats.greaterMinionsBuilt
		competitor.lesserMinionsBuilt += team.stats.lesserMinionsBuilt
		competitor.foxesBuilt += team.stats.foxesBuilt
		competitor.tanksBuilt += team.stats.tanksBuilt
		competitor.gruntsBuilt += team.stats.gruntsBuilt
		competitor.archersBuilt += team.stats.archersBuilt
		competitor.seersBuilt += team.stats.seersBuilt
		competitor.minersBuilt += team.stats.minersBuilt
		competitor.goldMined += team.goldMined
		
module.exports = Match