CommandParser = require './commandParser'
Constants = require '../settings/constants'
Competitor = require './competitor'
Duel = require 'duel'
EventBus = require '../eventBus'
FS = require 'fs'
GameStatus = require './gameStatus'
Helpers = require '../helpers'
Logger = require '../utilities/logger'
Match = require './match'
Mkdirp = require 'mkdirp'
Mongo = require '../utilities/mongoClient'
Path = require 'path'
Q = require 'q'
ServerStatus = require '../serverStatus'
Util = require 'util'
UUID = require 'node-uuid'

class Bracket
	constructor: () ->
		@competitor1 = null
		@competitor2 = null
		@match = null
		@winnerBracket = null
		@loserBracket = null

# Takes in a list of teams and creates a single elimination bracket-style tournament between them
# Seeds/Byes are chosen at random
# Multiple games will run at a time
# Only one round runs at a time
class BracketTournament
	constructor: (@competitors, callback) ->
		@id = UUID.v1()
		makeTourneyFolder (tourneyFolder) =>
			@tourneyFolder = tourneyFolder
			@rounds = [[]]
			@round = 1
			@matchesInProgress = 0
			@shuffleCompetitors()
			@chopCompetitorsNames()
			@duel = new Duel @competitors.length, { last: Duel.LB }
			Logger.log "Duel: #{Util.inspect @duel, { depth: null }}"
			@buildRound()
			EventBus.publish 'scoreboard', @getScoreboard()
			callback()

	# enforces the max team name length by chopping off extra characters
	chopCompetitorsNames: () ->
		for comp in @competitors
			if comp.name.length > Constants.tournament.maxTeamNameLength
				comp.name = comp.name.substring 0, 25

	# creates all matches for the current round
	buildRound: () ->
		return if @matchesInProgress > 0
		matches = @duel.findMatches({ r: @round, s: 1 }).concat @duel.findMatches({ r: @round - 1, s: 2 })
		Logger.log "round #{@round}"
		Logger.log "::::::::::"
		Logger.log Util.inspect matches
		for match in matches
			if match.p[0] >= 1
				competitorA = @competitors[match.p[0] - 1]
			else competitorA = null
			if match.p[1] >= 1
				competitorB = @competitors[match.p[1] - 1]
			else competitorB = null
			m = new Match @id, match.id, competitorA, competitorB, Constants.tournament.bracketGamesPerMatch, false, @tourneyFolder
			@rounds[@round - 1].push m

	# starts all matches in the current round
	startRound: () ->
		return if @matchesInProgress > 0
		@matchesInProgress = @rounds[@round - 1].length
		for match in @rounds[@round - 1]
			match.start @matchOver

	# randomly shuffle the competitors using the Fisher-Yates Shuffle
	shuffleCompetitors: () ->
		counter = @competitors.length
		while counter--
			index = (Math.random() * counter) | 0
			temp = @competitors[counter]
			@competitors[counter] = @competitors[index]
			@competitors[index] = temp

	# called when a match finishes, checks if the round and/or tournament is over
	matchOver: (match) =>
		@matchesInProgress--
		Logger.log "Match finished: #{Util.inspect match.id}"
		if (match.winner is match.competitor1)
			@duel.score match.id, [1, 0] if match.competitor2 isnt null
		else 
			@duel.score match.id, [0, 1] if match.competitor1 isnt null
		return if @matchesInProgress > 0
		if @duel.isDone()
			@finishedFunction()
			EventBus.publish 'scoreboard', @getScoreboard()
		else
			@rounds.push []
			@round++
			@buildRound()
			EventBus.publish 'scoreboard', @getScoreboard()
			EventBus.publish 'round over'

	# returns an object representing the tournament bracket with all of the matches
	getScoreboard: () ->
		winners = @duel.findMatches { s: 1 }
		losers = @duel.findMatches { s: 2 }
		w = []
		l = []
		for round in @rounds
			for match in round
				m =
					compA: match.competitor1
					compB: match.competitor2
					winner: match.winner
					x: match.id.r - 1
					y: match.id.m - 1
				w.push m if match.id.s is 1
				l.push m if match.id.s is 2
		return {
			winnersBracket: w
			losersBracket: l
		}


	# returns a string representing the tournament results
	getStandings: () ->
		standings = "TOURNAMENT RESULTS:\r\n--------------\r\n"
		whitespace = ""
		for i in [9...Constants.tournament.maxTeamNameLength]
			whitespace += " "
		standings += "Team Name#{whitespace}Record\t\tPlace\r\n"
		for entry in @duel.results()
			competitor = @competitors[entry.seed - 1]
			name = competitor.name
			while name.length < Constants.tournament.maxTeamNameLength
				name += " "
			standings += "#{name} #{entry.for} - #{entry.against}\t\t #{entry.pos}"
			standings += "\r\n"
		return standings

	# called when the tournament is complete, writes the results to files
	finishedFunction: () ->
		Logger.log "tournament complete"
		Logger.log "winner: #{@competitors[@duel.results()[0].seed - 1].name}"
		standings = @getStandings()
		Logger.log standings
		EventBus.publish "results", standings
		resultPath = Path.join @tourneyFolder, "/RESULTS.txt"
		FS.writeFile resultPath, standings

# Takes in a list of teams and runs all of our simulations using them
# The tournament has each match play x number of times where one team goes first and x number of times where the other goes first
# Multiple matches will be running at a time
# Whenever a match ends we check to see if anyone waiting to play a match has the next player they are waiting for available and we kick off that match
class RoundRobinTournament
	constructor: ->
		@id = UUID.v1()

	# adds the list of matches for each competitor
	addMatchesForCompetitors: () ->
		for competitor1 in @competitors
			for competitor2 in @competitors
				#only add matches for one competitor
				if competitor1.id < competitor2.id
					competitor1.addMatch competitor2
			competitor1.shuffleMatches()

	# creates matches for competitors and starts them
	executeTournament: (@competitors) ->
		if @competitors.length is 0
			throw new Error "Can\'t start a tournament with no competitors..."
		@matches = []
		@nextMatchId = 1
		tournament = @
		makeTourneyFolder()
		.then (tourneyFolder) ->
			tournament.tourneyFolder = tourneyFolder
			tournament.addMatchesForCompetitors()
			tournament.startGames()
		.catch (err) ->
			Logger.error "Could not create tourney folder... tournament not started"
			Logger.error err

	# called when the tournament finishes, writes matches and results to files
	finishedFunction: () ->
		scoreboard = @getScoreboard()
		standings = @getStandings()
		Logger.log standings
		resultPath = Path.join @tourneyFolder, "/RESULTS.txt"
		FS.writeFile resultPath, standings
		Mongo.addRoundRobinTournament(@, scoreboard, standings)
		.catch (error) ->
			Logger.error "DB ERROR: Could not add round robin tournament"
			Logger.error error
		.then (tournament) ->
			ServerStatus.runningTournament = false
			require("../standings/standings").addTournament(tournament)

	# returns an object representing the competitors, their matches, and their stats
	getScoreboard: () ->
		scoreboard = []
		for c in @competitors
			c.wins = 0
			c.losses = 0
			scoreboard.push c
		for m in @matches
			for g in m.games
				continue if not g.isOver()
				winner = g.getWinner()
				loser = g.getLoser()
				for c in scoreboard
					if c.name is winner.name
						c.wins++
					if c.name is loser.name
						c.losses++
		# Sort by wins and then by gold mined and then by minions killed
		scoreboard.sort (a, b) ->
			if b.wins isnt a.wins then return b.wins - a.wins
			if b.goldMined isnt a.goldMined then return b.goldMined - a.goldMined
			return b.minionsKilled - a.minionsKilled
		return scoreboard
			
	# returns a string representing the tournament results
	getStandings: () ->
		scoreboard = @getScoreboard()
		standings = "TOURNAMENT RESULTS:\r\n--------------\r\n"
		for entry in scoreboard
			standings += "#{entry.name}: #{entry.wins} - #{entry.losses}\r\n"
		return standings

	# called when a match is finished
	matchOver: (match) ->
		# check if tournament is over, if it isn't then start more games
		tournamentOver = true
		for competitor in @competitors
			tournamentOver = false if competitor.stillHasGames()
		if tournamentOver
			process.nextTick () => @finishedFunction()
		else @startGames()

	# looks at all teams waiting to play their next game to see if any pairs are free
	startGames: () ->
		for competitor in @competitors
			otherCompetitor = competitor.getOpponent()
			continue if otherCompetitor is null
			match = new Match @id, UUID.v1(), competitor, otherCompetitor, Constants.tournament.roundRobinGamesPerMatch, true, @tourneyFolder
			competitor.foundMatch()
			@matches.push match
			tournament = @
			match.start()
			.then (finishedMatch) ->
				tournament.matchOver finishedMatch

#----------------
# Private Methods
#----------------
makeTourneyFolder = () ->
	d = new Date()
	tourneyNum = 1
	tourneyFolder = "tourney #{tourneyNum}"
	monthNames = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ]
	month = monthNames[d.getMonth()]
	dateFolder = Path.join "" + d.getFullYear(), month, "" + d.getDate(), tourneyFolder
	while FS.existsSync Path.join __dirname, "../../matches/tournaments/", dateFolder
		tourneyNum++
		tourneyFolder = "tourney #{tourneyNum}"
		dateFolder = Path.join "" + d.getFullYear(), month, "" + d.getDate(), tourneyFolder
	fullPath = Path.join __dirname, "../../matches/tournaments/", dateFolder
	Helpers.makeDirectoryRecursively fullPath

module.exports = 
	RoundRobinTournament: RoundRobinTournament
	BracketTournament: BracketTournament