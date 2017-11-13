Logger = require '../utilities/logger'
Mongo = require '../utilities/mongoClient'
Helpers = require '../helpers'
Messaging = require '../messaging'
Q = require 'q'

#holds all tournaments in memory for requests from the standings page
#queries for specific tournament information
class Standings
	tournamentCache = []

	#---------------
	# Public Methods
	#---------------

	# adds a tournament from the db to our 'cache'
	addTournament: (tournament) ->
		# get extra competitor info for the tournament winner
		Mongo.getCompetitor({ name: tournament.scoreboard[0].name }, winningCompetitorFields)
		.catch (err) ->
			Logger.error 'DB ERROR: could not get competitor in tournament'
			Logger.error err
			throw err
		.then (competitor) ->
			if competitor is null
				Logger.error "Could not find winner of tournament #{tournamentId}"
				throw new Error Messaging.ServerError
			tournament.scoreboard[0].api_url = competitor.api_url
			cachedTournament = tournamentFromDbTournament tournament
			tournamentCache.push cachedTournament
			tournamentCache = tournamentCache.sort Helpers.sortTournamentsDescending
			updateReigns()

	# Clears our cache
	clear: ->
		tournamentCache = []

	# Gets all details for the competitor page
	getCompetitorDetails: (name) ->
		Mongo.getCompetitor({name: name})
		.catch (err) ->
			Logger.error 'DB ERROR: Could not get competitor'
			Logger.error err
			throw err
		.then (dbCompetitor) ->
			if not dbCompetitor then throw new Error Messaging.Standings.CompetitorNotFound
			competitorTournaments = []
			for tournament in tournamentCache
				for i in [0...tournament.scoreboard.length]
					if tournament.scoreboard[i].name is name
						competitorTournaments.push
							goldMined: tournament.scoreboard[i].goldMined
							wins: tournament.scoreboard[i].wins
							losses: tournament.scoreboard[i].losses
							minionsKilled: tournament.scoreboard[i].minionsKilled
							minersBuilt: tournament.scoreboard[i].minersBuilt
							archersBuilt: tournament.scoreboard[i].archersBuilt
							seersBuilt: tournament.scoreboard[i].seersBuilt
							foxesBuilt: tournament.scoreboard[i].foxesBuilt
							tanksBuilt: tournament.scoreboard[i].tanksBuilt
							gruntsBuilt: tournament.scoreboard[i].gruntsBuilt
							greaterMinionsBuilt: tournament.scoreboard[i].greaterMinionsBuilt
							lesserMinionsBuilt: tournament.scoreboard[i].lesserMinionsBuilt
							name: tournament.name
							id: tournament.id
							position: Helpers.getOrdinal i + 1
							numCompetitors: tournament.scoreboard.length
			competitor = competitorFromDbCompetitor dbCompetitor
			competitor.tournaments = competitorTournaments
			competitor

	# Gets the details of matches for a competitor in a tournament for the competitor page
	getCompetitorTournamentMatches: (competitorName, tournamentId) ->
		Mongo.getRoundRobinTournament(tournamentId, {matches: true, scoreboard: true})
		.catch (err) ->
			Logger.error 'DB ERROR: Could not get tournament'
			Logger.error err
			throw err
		.then (tournament) ->
			if not tournament
				Logger.info "Could not get tournament by id: #{tournamentId}"
				throw new Error Messaging.Standings.TournamentNotFound
			# error if competitor wasn't in tournament
			inTournament = false
			for s in tournament.scoreboard
				if s.name is competitorName then inTournament = true
			if not inTournament
				Logger.info "Competitor #{competitorName} is not in tournament #{tournamentId}"
				throw new Error Messaging.ServerError
			# build matches
			matches = []
			for m in tournament.matches
				if m.competitor1.name is competitorName or m.competitor2.name is competitorName
					result = 'loss'
					if m.winner is competitorName then result = 'win'
					if m.winner is 'DRAW' then result = 'draw'
					if m.competitor1.name is competitorName
						opponent = m.competitor2.name
					else opponent = m.competitor1.name
					games = []
					for game in m.games
						if game.winner is competitorName then gameResult = 'win' else gameResult = 'loss'
						games.push
							result: gameResult
							path: game.path
					matches.push
						games: games
						result: result
						opponent: opponent
			matches

	# Returns total aggregated stats for the main standings page
	getGlobalDetails: ->
		numCompetitors = 0
		gamesPlayed = 0
		for tournament in tournamentCache
			gamesPlayed += tournament.numGames
			if tournament.scoreboard.length > numCompetitors
				numCompetitors = tournament.scoreboard.length
		Mongo.getCompetitorAggregate(competitorAggregate)
		.catch (err) ->
			Logger.error 'DB ERROR: Could not get stats from competitors'
			Logger.error err
			throw err
		.then (dbAggregate) ->
			stats = statsFromDbStats dbAggregate
			stats.gamesPlayed = gamesPlayed
			stats.codeWarriors = numCompetitors
			stats

	getKingApi: ->
		if tournamentCache.length is 0 then return '' else return tournamentCache[0].scoreboard[0].api_url

	# Return a cached tournament by id
	getTournament: (tournamentId) ->
		tournament = null
		# find the tournament with the given id and store the index of it
		for i in [0...tournamentCache.length]
			if tournamentCache[i].id is tournamentId
				tournament = tournamentCache[i]
		# error out if we didn't find the tournament
		if not tournament
			return tournamentNotFoundError(tournamentId)
		Helpers.promisedData tournament

	# Get a list of all tournament ids and names
	getTournamentNames: ->
		names = []
		for tournament in tournamentCache
			names.push
				id: tournament.id
				name: tournament.name
		names

	# Gets all cached tournaments
	getTournaments: ->
		tournamentCache

	# Clear the cache and reload it
	initialize: ->
		@clear()
		_this = @
		Mongo.getRoundRobinTournaments()
		.catch (error) ->
			Logger.error 'DB ERROR: Could not load tournaments...'
			Logger.error err
			throw err
		.then (dbTournaments) ->
			promises = []
			if dbTournaments
				for tournament in dbTournaments
					promises.push(_this.addTournament(tournament))
				Logger.info "loading #{dbTournaments.length} tournaments into cache"
			else
				Logger.info 'dbTournaments is null'
			Q.all(promises)

	#----------------
	# Private Methods
	#----------------

	# Aggregate pipeline to sum up competitor stats
	competitorAggregate = [
		{
			$group:
				_id: ""
				gold_mined: { $sum: "$gold_mined" }
				minions_killed: { $sum: "$minions_killed" }
				miners_built: { $sum: "$miners_built" }
				archers_built: { $sum: "$archers_built" }
				seers_built: { $sum: "$seers_built" }
				foxes_built: { $sum: "$foxes_built" }
				tanks_built: { $sum: "$tanks_built" }
				greater_minions_built: { $sum: "$greater_minions_built" }
				lesser_minions_built: { $sum: "$lesser_minions_built" }
		}
		{
			$project:
				_id: 0
				gold_mined: "$gold_mined"
				minions_killed: "$minions_killed"
				miners_built: "$miners_built"
				archers_built: "$archers_built"
				seers_built: "$seers_built"
				foxes_built: "$foxes_built"
				tanks_built: "$tanks_built"
				greater_minions_built: "$greater_minions_built"
				lesser_minions_built: "$lesser_minions_built"
		}
	]

	# Convert db competitor to competitor to return to client
	competitorFromDbCompetitor = (competitor) ->
		return {
			name: competitor.name
			email: competitor.email
			registeredOn: Helpers.getStringFromDateStamp competitor.registered_on
			goldMined: competitor.gold_mined
			gameWins: competitor.game_wins
			gameLosses: competitor.game_losses
			matchWins: competitor.match_wins
			matchLosses: competitor.match_losses
			matchDraws: competitor.match_draws
			minionsKilled: competitor.minions_killed
			minersBuilt: competitor.miners_built
			archersBuilt: competitor.archers_built
			seersBuilt: competitor.seers_built
			foxesBuilt: competitor.foxes_built
			tanksBuilt: competitor.tanks_built
			gravatar: competitor.gravatar
			blurb: competitor.blurb
			greaterMinionsBuilt: competitor.greater_minions_built
			lesserMinionsBuilt: competitor.lesser_minions_built
			gruntsBuilt: competitor.grunts_built
		}

	# Convert the db stats aggregate to data to be returned to client
	statsFromDbStats = (dbStats) ->
		if not dbStats.gold_mined then dbStats.gold_mined = 0
		if not dbStats.minions_killed then dbStats.minions_killed = 0
		if not dbStats.miners_built then dbStats.miners_built = 0
		if not dbStats.archers_built then dbStats.archers_built = 0
		if not dbStats.seers_built then dbStats.seers_built = 0
		if not dbStats.foxes_built then dbStats.foxes_built = 0
		if not dbStats.tanks_built then dbStats.tanks_built = 0
		if not dbStats.greater_minions_built then dbStats.greater_minions_built = 0
		if not dbStats.lesser_minions_built then dbStats.lesser_minions_built = 0
		return {
			goldMined: dbStats.gold_mined
			minionsKilled: dbStats.minions_killed
			minersBuilt: dbStats.miners_built
			archersBuilt: dbStats.archers_built
			seersBuilt: dbStats.seers_built
			foxesBuilt: dbStats.foxes_built
			tanksBuilt: dbStats.tanks_built
			greaterMinionsBuilt: dbStats.greater_minions_built
			lesserMinionsBuilt: dbStats.lesser_minions_built
		}

	# Convert a tournament from db to one to store in cache
	tournamentFromDbTournament = (dbTournament) ->
		tournament =
			name: Helpers.getStringFromDateStamp dbTournament.date
			date: dbTournament.date
			scoreboard: dbTournament.scoreboard
			id: dbTournament._id.toHexString()
			numGames: dbTournament.matches.length * dbTournament.games_per_match
			minionsKilled: 0
			greaterMinionsBuilt: 0
			lesserMinionsBuilt: 0
			foxesBuilt: 0
			tanksBuilt: 0
			gruntsBuilt: 0
			archersBuilt: 0
			seersBuilt: 0
			minersBuilt: 0
			goldMined: 0
		# get sum of competitor stats and rename stats
		for c in tournament.scoreboard
			# minions killed
			tournament.minionsKilled += c.minions_killed
			c.minionsKilled = c.minions_killed
			delete c.minions_killed
			# greater minions built
			tournament.greaterMinionsBuilt += c.greater_minions_built
			c.greaterMinionsBuilt = c.greater_minions_built
			delete c.greater_minions_built
			# lesser minions built
			tournament.lesserMinionsBuilt += c.lesser_minions_built
			c.lesserMinionsBuilt = c.lesser_minions_built
			delete c.lesser_minions_built
			tournament.foxesBuilt += c.foxes_built
			c.foxesBuilt = c.foxes_built
			delete c.foxes_built
			tournament.tanksBuilt += c.tanks_built
			c.tanksBuilt = c.tanks_built
			delete c.tanks_built
			tournament.gruntsBuilt += c.grunts_built
			c.gruntsBuilt = c.grunts_built
			delete c.grunts_built
			tournament.archersBuilt += c.archers_built
			c.archersBuilt = c.archers_built
			delete c.archers_built
			tournament.seersBuilt += c.seers_built
			c.seersBuilt = c.seers_built
			delete c.seers_built
			tournament.minersBuilt += c.miners_built
			c.minersBuilt = c.miners_built
			delete c.miners_built
			tournament.goldMined += c.gold_mined
			c.goldMined = c.gold_mined
			delete c.gold_mined
		tournament

	# Promise wrapper to throw tournament not found error
	tournamentNotFoundError = (tournamentId) ->
		deferred = Q.defer()
		Logger.info "could not find tournament of id #{tournamentId}"
		process.nextTick ->
			deferred.reject new Error Messaging.Standings.TournamentNotFound
		deferred.promise

	# Update the reign property of each tournament winner
	updateReigns = ->
		for i in [0...tournamentCache.length]
			winner = tournamentCache[i].scoreboard[0]
			reign = 1
			reignOver = false
			for j in [i+1...tournamentCache.length]
				continue if reignOver
				if winner.name is tournamentCache[j].scoreboard[0].name
					reign++
				else reignOver = true
			winner.reign = "#{Helpers.getOrdinal(reign)} week"

	# Extra fields to pull from the winning competitor for the tournament standings page
	winningCompetitorFields =
		name: true
		api_url: true

module.exports = new Standings()