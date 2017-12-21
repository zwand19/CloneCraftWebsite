Config = require '../config.json'
Mongo = require 'mongodb'
Mongo.BSONPure = require('bson').BSONPure
Constants = require '../settings/constants'
Helpers = require '../helpers'
Q = require "q"
Logger = require './logger'

# Handles talking to mongo db
class MongoClient
	_connStr = Config.mongodb_url

	#-----------------------------------------
	# Public methods for testing purposes only
	#-----------------------------------------

	changeConnection: (conn) ->
		_connStr = conn

	removeCompetitor: (query) ->
		executeCompetitorsFunc "remove", query

	addTournament: (tournament) ->
		executeTournamentsFunc "insert", tournament

	removeTournament: (query) ->
		executeTournamentsFunc "remove", query

	#---------------
	# Public methods
	#---------------

	addCompetitor: (competitor) ->
		executeCompetitorsFunc("insert", competitor)
			.then (response) ->
				response.ops[0]

	getCompetitor: (query, fields) ->
		executeCompetitorsFunc "findOne", query, fields

	getCompetitors: (query, fields) ->
		executeCompetitorsFunc "find", query, fields, (result) -> result.toArray()

	getNewCompetitorPort: ->
		executeCompetitorsFunc("findOne", {port: {$exists: true}}, {sort: [["port", "desc"]]})
			.then (competitor) ->
				if competitor then return competitor.port + 1 else return 3000

	getCompetitorAggregate: (aggregate) ->
		executeCompetitorsFunc("aggregate", aggregate)
			.then (results) ->
				if results?[0] then return results[0] else return {}

	findAndModifyCompetitor: (query, modification) ->
		database = null
		connect()
			.then (db) ->
				database = db
				Q.ninvoke(database, "collection", "competitors")
			.then (coll) ->
				Q.ninvoke(coll, "findAndModify", query, [], modification, {new:true})
			.then (competitors) ->
				database.close()
				competitors[0]

	getRoundRobinTournament: (id, fields) ->
		executeTournamentsFunc "findOne", { _id: new Mongo.BSONPure.ObjectID(id) }, fields

	getRoundRobinTournaments: ->
		executeTournamentsFunc "find", {}, null , (result) -> result.toArray()

	addRoundRobinTournament: (tournament, scoreboard, standings) ->
		dbTourney = buildDbTournamentFromTournament(tournament, scoreboard, standings)
		executeTournamentsFunc "insert", dbTourney, null, (tournaments) ->
			tournaments[0]

	#----------------
	# Private methods
	#----------------

	connect = () ->		
		Q.nfcall Mongo.connect, _connStr

	buildDbTournamentFromTournament = (tournament, scoreboard, standings) ->
		date: Helpers.getDateStamp()
		matches: buildDbMatchesFromTournament tournament
		games_per_match: Constants.tournament.roundRobinGamesPerMatch
		scoreboard: buildDbScoreboard scoreboard
		standings: standings
		folder: tournament.tourneyFolder
		id: tournament.id

	buildDbMatchesFromTournament = (tournament) ->
		dbMatches = []
		for match in tournament.matches
			dbMatches.push buildDbMatchFromTournamentMatch(match)
		dbMatches

	buildDbMatchFromTournamentMatch = (match) ->
		dbMatch =
			games: buildDbGamesFromTournamentMatch match
			winner: if match.winner then match.winner.name else "DRAW"
			competitor1: buildDbCompetitorFromCompetitor match.competitor1
			competitor2: buildDbCompetitorFromCompetitor match.competitor2
		dbMatch

	buildDbCompetitorFromCompetitor = (competitor) ->
		id: competitor.id
		name: competitor.name

	buildDbGamesFromTournamentMatch = (match) ->
		dbGames = []
		for game in match.games
			dbGames.push
				loser: game.getLoser().name
				name: "#{game.teams[0].name} vs. #{game.teams[1].name}"
				path: game.zipPath
				winner: game.getWinner().name
				id: game.id
		dbGames

	buildDbScoreboard = (scoreboard) ->
		dbScoreboard = []
		for c in scoreboard
			dbScoreboard.push
				name: c.name
				wins: c.wins
				losses: c.losses
				gravatar: c.gravatar
				minions_killed: c.minionsKilled
				greater_minions_built: c.greaterMinionsBuilt
				lesser_minions_built: c.lesserMinionsBuilt
				foxes_built: c.foxesBuilt
				tanks_built: c.tanksBuilt
				grunts_built: c.gruntsBuilt
				archers_built: c.archersBuilt
				seers_built: c.seersBuilt
				miners_built: c.minersBuilt
				gold_mined: c.goldMined
		dbScoreboard

	executeCompetitorsFunc = (func, param1, param2, promiseFunc) ->
		executeCollectionFunc "competitors", func, param1, param2, promiseFunc

	executeTournamentsFunc = (func, param1, param2, promiseFunc) ->
		executeCollectionFunc "round_robin_tournaments", func, param1, param2, promiseFunc

	executeCollectionFunc = (collectionName, func, param1, param2, promiseFunc) ->
		database = null
		connect()
			.then (db) ->
				database = db
				Q.ninvoke(db, "collection", collectionName)
			.then (coll) ->
				if param2?
					Q.ninvoke(coll, func, param1, param2)
				else
					Q.ninvoke(coll, func, param1)
			.then (result) ->
				if (promiseFunc?)
					promiseFunc(result)
				else
					result
			.then (result) ->
				database.close()
				result

module.exports = new MongoClient()