Competitor = require '../game/competitor'
Logger = require './logger'
Mongo = require './mongoClient'
Q = require 'q'
Scheduler = require 'node-schedule'
ServerStatus = require '../serverStatus'
Tournament = require '../game/tournament'

class TournamentScheduler
	runTournament: ->
		Logger.log '!!!!!!!!!!!!!!!!!!!!!'
		Logger.log 'IT\'S TOURNAMENT TIME'
		Logger.log '!!!!!!!!!!!!!!!!!!!!!'
		ServerStatus.runningTournament = true
		Mongo.getCompetitors({confirmed: true})
		.catch (err) ->
			Logger.error 'DB ERROR: could not get confirmed competitors'
			Logger.error 'Tournament not scheduled...'
			Logger.error err
		.then (competitors) ->
			tourneyCompetitors = []
			for competitor in competitors
				tourneyCompetitors.push new Competitor competitor._id.toHexString(), competitor.name, competitor.apiUrl, competitor.gravatar
			Logger.log 'COMPETITORS: ', tourneyCompetitors
			tournament = new Tournament.RoundRobinTournament()
			tournament.executeTournament(tourneyCompetitors)
		.catch (err) ->
			Logger.error 'CRITICAL ERROR: Tournament not scheduled...'
			Logger.error err

	scheduleTournament: (schedule) ->
		Scheduler.scheduleJob schedule, =>
			@runTournament()

module.exports = new TournamentScheduler()