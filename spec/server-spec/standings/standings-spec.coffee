Helpers = require '../../../server/helpers'
Logger = require '../../../server/utilities/logger'
Mongo = require '../../../server/utilities/mongoClient'
Q = require 'q'
Standings = require '../../../server/standings/standings'
TestHelpers = require '../../testHelpers'

describe 'Standings', ->
	#----------
	# Test data
	#----------
	competitor = 
		name: 'johnnyd'
		email: 'johnnyd@geneca.com'
		language: 'C-Sharp'
		registered_on: '05/12/2014 10:14:00'
		uploads: 14
		gold_mined: 10242
		game_wins: 162
		game_losses: 52
		match_wins: 22
		match_losses: 8
		match_draws: 1
		minions_killed: 241
		miners_built: 160
		archers_built: 242
		seers_built: 191
		foxes_built: 214
		tanks_built: 0
		gravatar: 'www.gravatar.com/comp'
		last_uploaded: '05/17/2014 10:29:11'
		greater_minions_built: 160 + 242 + 191 + 214 + 5 - 51
		lesser_minions_built: 51
		grunts_built: 5

	competitorAggregate =
		uploads: 4
		gold_mined: 10290
		minions_killed: 1510
		miners_built: 123
		archers_built: 301
		seers_built: 21
		foxes_built: 10
		tanks_built: 2
		greater_minions_built: 122
		lesser_minions_built: 1412
	
	getTourney1 = () ->
		tourney = JSON.parse(JSON.stringify(
			'date' : '2014/06/05'
			'matches' : [
				{
					'competitor1':
						'id': '422'
						'name': 'johnnyd'
					'competitor2':
						'id': '421'
						'name': 'zwand'
					'winner': 'johnnyd'
					'games': [
						'loser': 'zwand'
						'winner': 'johnnyd'
						'path': 'path/to/game/1'
					,
						'loser': 'zwand'
						'winner': 'johnnyd'
						'path': 'path/to/game/2'
					,
						'winner': 'zwand'
						'loser': 'johnnyd'
						'path': 'path/to/game/3'
					,
						'loser': 'zwand'
						'winner': 'johnnyd'
						'path': 'path/to/game/4'
					,
						'loser': 'zwand'
						'winner': 'johnnyd'
						'path': 'path/to/game/5'
					,
						'loser': 'zwand'
						'winner': 'johnnyd'
						'path': 'path/to/game/6'
					]
				}
			,
				
				{
					'competitor2':
						'id': '422'
						'name': 'johnnyd'
					'competitor1':
						'id': '420'
						'name': 'bbob'
					'winner': 'DRAW'
					'games': [
						'loser': 'bbob'
						'winner': 'johnnyd'
						'path': 'path/to/game/1'
					,
						'loser': 'bbob'
						'winner': 'johnnyd'
						'path': 'path/to/game/2'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/3'
					,
						'loser': 'bbob'
						'winner': 'johnnyd'
						'path': 'path/to/game/4'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/5'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/6'
					]
				}
			,
				
				{
					'competitor2':
						'id': '422'
						'name': 'johnnyd'
					'competitor1':
						'id': '420'
						'name': 'bbob'
					'winner': 'bbob'
					'games': [
						'loser': 'bbob'
						'winner': 'johnnyd'
						'path': 'path/to/game/1'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/2'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/3'
					,
						'loser': 'bbob'
						'winner': 'johnnyd'
						'path': 'path/to/game/4'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/5'
					,
						'winner': 'bbob'
						'loser': 'johnnyd'
						'path': 'path/to/game/6'
					]
				}
			,
				
				{
					'competitor2':
						'id': '421'
						'name': 'zwand'
					'competitor1':
						'id': '420'
						'name': 'bbob'
					'winner': 'bbob'
					'games': [
						'loser': 'bbob'
						'winner': 'zwand'
						'path': 'path/to/game/1'
					,
						'winner': 'bbob'
						'loser': 'zwand'
						'path': 'path/to/game/2'
					,
						'winner': 'bbob'
						'loser': 'zwand'
						'path': 'path/to/game/3'
					,
						'loser': 'bbob'
						'winner': 'zwand'
						'path': 'path/to/game/4'
					,
						'winner': 'bbob'
						'loser': 'zwand'
						'path': 'path/to/game/5'
					,
						'winner': 'bbob'
						'loser': 'zwand'
						'path': 'path/to/game/6'
					]
				}
			],
			'games_per_match' : 6,
			'scoreboard' : [
				'name' : 'johnnyd'
				'wins' : 12,
				'losses' : 0,
				'archers_built': 34,
				'gravatar' : 'http://www.gravatar.com/avatar/361f4923dd2d84364ba8502a508dd07f?s=350&d=http%3A%2F%2Fwiseheartdesign.com%2Fimages%2Farticles%2Fdefault-avatar.png'
			, 
				'name' : 'zwand'
				'wins' : 3,
				'losses' : 9,
				'archers_built': 14,
				'gravatar' : 'http://www.gravatar.com/avatar/775724a0b43a97b6c42a4b6861eceb65?s=350&d=http%3A%2F%2Fwiseheartdesign.com%2Fimages%2Farticles%2Fdefault-avatar.png'
			, 
				'name' : 'bbob'
				'wins' : 3,
				'losses' : 9,
				'archers_built': 21,
				'gravatar' : 'http://www.gravatar.com/avatar/5e828f803b832bf4d8527b9140146275?s=350&d=http%3A%2F%2Fwiseheartdesign.com%2Fimages%2Farticles%2Fdefault-avatar.png'
			],
			'standings' : 'TOURNAMENT RESULTS:\r\n--------------\r\njohnnyd: 12 - 0\r\nzwand: 3 - 9\r\nbbob: 3 - 9\r\n'
			'folder' : 'matches\\tournaments\\2014\\June\\5\\tourney 1'))
		tourney._id =
			toHexString: () -> '53909642ea7e0b882c4d617b'
		tourney

	getTourney2 = () ->
		tourney = JSON.parse(JSON.stringify(
			'date' : '2014/05/04'
			'matches' : [
				{}, {}, {}, {}
			],
			'games_per_match' : 3,
			'scoreboard' : [
				'name' : 'johnnyd'
				'wins' : 11,
				'losses' : 1,
				'archers_built': 31,
				'gravatar' : 'http://www.gravatar.com/avatar/361f4923dd2d84364ba8502a508dd07f?s=350&d=mm'
			, 
				'name' : 'zwand'
				'wins' : 5,
				'losses' : 7,
				'archers_built': 24,
				'gravatar' : 'http://www.gravatar.com/avatar/775724a0b43a97b6c42a4b6861eceb65?s=350&d=mm'
			, 
				'name' : 'bbob'
				'wins' : 2,
				'losses' : 10,
				'archers_built': 18,
				'gravatar' : 'http://www.gravatar.com/avatar/5e828f803b832bf4d8527b9140146275?s=350&d=mm'
			],
			'standings' : 'TOURNAMENT RESULTS:\r\n--------------\r\njohnnyd: 11 - 1\r\nzwand: 5 - 7\r\nbbob: 2 - 10\r\n'
			'folder' : 'matches\\tournaments\\2014\\June\\5\\tourney 2'))
		tourney._id =
			toHexString: () -> 'laksmdlksad3oi32lkn320932'
		tourney

	getWinningCompetitor = () ->
		JSON.parse(JSON.stringify(
			code_folder: 'folder/subfolder'
			name: 'johnnyd'
			last_uploaded: '2014/06/11 17:19:49'
			gravatar: 'http://www.gravatar.com/avatar/361f4923dd2d84364ba8502a508dd07f?s=350&d=mm'
			id: 'as213sad-213asd'
			language: 'Node'
		))

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Mongo, 'getRoundRobinTournaments').andCallFake(TestHelpers.promisedData([getTourney1(), getTourney2()]))
		spyOn(Mongo, 'getCompetitorAggregate').andCallFake(TestHelpers.promisedData(competitorAggregate))
		spyOn(Mongo, 'getCompetitor').andCallFake(TestHelpers.promisedData(competitor))
		spyOn(Mongo, 'getRoundRobinTournament').andCallFake(TestHelpers.promisedData(getTourney1()))
		Standings.clear()

	#-----------
	# Unit Tests
	#-----------
	describe 'addTournament', ->
		it 'should set numGames on tournaments', (done) ->
			Standings.addTournament(getTourney1())
			.then () ->
				Standings.addTournament(getTourney2())
			.then () ->
				expect(Standings.getTournaments()[0].numGames).toBe(24)
				expect(Standings.getTournaments()[1].numGames).toBe(12)
			.catch (err) ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should convert tournament date to its readable name', (done) ->
			Standings.addTournament(getTourney1())
			.then () ->
				Standings.addTournament(getTourney2())
			.then () ->
				expect(Standings.getTournaments()[0].name).toBe('June 5th 2014')
				expect(Standings.getTournaments()[1].name).toBe('May 4th 2014')
			.catch () ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should convert tournament object id to string', (done) ->
			Standings.addTournament(getTourney1())
			.then () ->
				Standings.addTournament(getTourney2())
			.then () ->
				expect(Standings.getTournaments()[0].id).toBe('53909642ea7e0b882c4d617b')
				expect(Standings.getTournaments()[1].id).toBe('laksmdlksad3oi32lkn320932')
			.catch () ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should keep tournaments in descending date order', (done) ->
			Standings.addTournament(getTourney2())
			.then () ->
				Standings.addTournament(getTourney1())
			.then () ->
				expect(Standings.getTournaments()[0].date).toBe('2014/06/05')
				expect(Standings.getTournaments()[1].date).toBe('2014/05/04')
			.catch (err) ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should build winning competitor for correct tournament', (done) ->
			Standings.addTournament(getTourney1())
			.then () ->
				Standings.addTournament(getTourney2())
			.then () ->
				expect(Standings.getTournaments()[0].scoreboard[0].wins).toBe(12)
				expect(Standings.getTournaments()[1].scoreboard[0].wins).toBe(11)
			.catch (err) ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should keep stats per competitor per tournament', (done) ->
			Standings.addTournament(getTourney1())
			.then () ->
				Standings.addTournament(getTourney2())
			.then () ->
				expect(Standings.getTournaments()[0].scoreboard[0].archersBuilt).toBe(34)
			.catch () ->
				TetsHelpers.fail()
			.done () ->
				done()

	describe 'getCompetitorDetails', ->
		it 'should return db details', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getCompetitorDetails('johnnyd')
			.then (details) ->
				expect(details.name).toBe('johnnyd')
				expect(details.email).toBe('johnnyd@geneca.com')
				expect(details.seersBuilt).toBe(191)
			.done () ->
				done()

		it 'should return stats per tournament', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getCompetitorDetails('johnnyd')
			.then (details) ->
				expect(details.tournaments[0].archersBuilt).toBe(34)
			.catch () ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should return basic tournament information', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getCompetitorDetails('johnnyd')
			.then (details) ->
				expect(details.tournaments.length).toBe(2)
			.done () ->
				done()

		it 'should throw db errors', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promiseError)
			failed = false
			Standings.initialize()
			.then () ->
				Standings.getCompetitorDetails('johnnyd')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

	describe 'getCompetitorTournamentMatches', ->
		it 'should return matches', (done) ->
			Standings.getCompetitorTournamentMatches('johnnyd', '53909642ea7e0b882c4d617b')
			.then (matches) ->
				expect(matches.length).toBe(3)
				expect(matches[0].result).toBe('win')
				expect(matches[0].opponent).toBe('zwand')
				expect(matches[0].games.length).toBe(6)
				expect(matches[0].games[0].result).toBe('win')
				expect(matches[0].games[0].path).toBe('path/to/game/1')
				expect(matches[0].games[2].result).toBe('loss')
				expect(matches[0].games[2].path).toBe('path/to/game/3')
				expect(matches[1].result).toBe('draw')
				expect(matches[1].opponent).toBe('bbob')
				expect(matches[1].games.length).toBe(6)
				expect(matches[2].result).toBe('loss')
				expect(matches[2].opponent).toBe('bbob')
				expect(matches[2].games.length).toBe(6)
			.catch () ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should throw db errors', (done) ->
			Mongo.getRoundRobinTournament.andCallFake(TestHelpers.promiseError)
			failed = false
			Standings.getCompetitorTournamentMatches('johnnyd', '53909642ea7e0b882c4d617b')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

	describe 'getGlobalDetails', ->
		it 'should return stats', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getGlobalDetails()
			.then (details) ->
				expect(details.codeUploads).toBe(4)
				expect(details.goldMined).toBe(10290)
				expect(details.minionsKilled).toBe(1510)
				expect(details.greaterMinionsBuilt).toBe(122)
			.done () ->
				done()

		it 'should return games played', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getGlobalDetails()
			.then (details) ->
				expect(details.gamesPlayed).toBe(36)
			.done () ->
				done()

		it 'should return code warriors', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getGlobalDetails()
			.then (details) ->
				expect(details.codeWarriors).toBe(3)
			.done () ->
				done()

		it 'should throw db errors', (done) ->
			Mongo.getCompetitorAggregate.andCallFake(TestHelpers.promiseError)
			failed = false
			Standings.initialize()
			.then () ->
				Standings.getGlobalDetails()
			.catch (err) ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

	describe 'getTournament', ->
		it 'should return tournament', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getTournament('53909642ea7e0b882c4d617b')
			.then (details) ->
				expect(details.scoreboard.length).toBe(3)
			.done () ->
				done()

		it 'should return tournament stat totals', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getTournament('53909642ea7e0b882c4d617b')
			.then (details) ->
				expect(details.archersBuilt).toBe(69)
			.done () ->
				done()

		it 'should query for winning competitor', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promisedData(getWinningCompetitor()))
			Standings.initialize()
			.then () ->
				Standings.getTournament('53909642ea7e0b882c4d617b')
			.then (details) ->
				expect(Mongo.getCompetitor).toHaveBeenCalled()
				args = Mongo.getCompetitor.calls[0].args
				expect(args[0].name).toBe('johnnyd')
			.done () ->
				done()
			
		it 'should return winning competitor details', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promisedData(getWinningCompetitor()))
			Standings.initialize()
			.then () ->
				Standings.getTournament('53909642ea7e0b882c4d617b')
			.then (details) ->
				expect(details.scoreboard[0].wins).toBe(12)
				expect(details.scoreboard[0].losses).toBe(0)
				expect(details.scoreboard[0].reign).toBe('2nd week')
				expect(details.scoreboard[0].lastUploaded).toBe('June 11th 2014')
			.done () ->
				done()
			
		it 'should update reign correctly', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promisedData(getWinningCompetitor()))
			Standings.initialize()
			.then () ->
				Standings.getTournament('laksmdlksad3oi32lkn320932')
			.then (details) ->
				expect(details.scoreboard[0].reign).toBe('1st week')
			.done () ->
				done()

		it 'should throw db errors', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promiseError)
			failed = false
			Standings.initialize()
			.then () ->
				Standings.getTournament('53909642ea7e0b882c4d617b')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

		it 'should throw error on invalid id', (done) ->
			failed = false
			Standings.initialize()
			.then () ->
				Standings.getTournament('lol')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

		it 'should throw error on undefined id', (done) ->
			failed = false
			Standings.initialize()
			.then () ->
				Standings.getTournament()
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

	describe 'getTournamentNames', ->
		it 'should return id and name', (done) ->
			Standings.initialize()
			.then () ->
				Standings.getTournamentNames()
			.then (names) ->
				expect(names.length).toBe(2)
				expect(names[0].id).toBe('53909642ea7e0b882c4d617b')
				expect(names[0].name).toBe('June 5th 2014')
				expect(names[1].id).toBe('laksmdlksad3oi32lkn320932')
				expect(names[1].name).toBe('May 4th 2014')
			.catch () ->
				TestHelpers.fail()
			.done () ->
				done()

	describe 'initialize', ->
		it 'can load tournaments', (done) ->
			Standings.initialize()
			.done () ->
				expect(Standings.getTournaments().length).toBe(2)
				done()

		it 'throws db errors', (done) ->
			Mongo.getRoundRobinTournaments.andCallFake(TestHelpers.promiseError)
			failed = false
			Standings.initialize()
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()
