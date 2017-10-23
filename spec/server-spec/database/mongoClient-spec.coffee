Logger = require '../../../server/utilities/logger'
Mongo = require '../../../server/utilities/mongoClient'
Q = require 'q'
Standings = require '../../../server/standings/standings'
TestHelpers = require '../../testHelpers'

#connStr = 'mongodb://test:test@kahana.mongohq.com:10094/CloneCraft_Testing'
connStr = 'mongodb://localhost:27017/clone_craft_test_db'
Mongo.changeConnection connStr

describe 'MongoClient', ->
	#----------
	# Test Data
	#----------
	competitors = [
		name: 'competitor one'
		age: 23
		iq: 100
		confirmed: true
		port: 26
		language: 'csharp'
		uploads: 1
	,
		name: 'competitor two'
		age: 25
		iq: 100
		confirmed: false
		port: 25
		language: 'node'
		uploads: 0
	,
		name: 'competitor three'
		age: 27
		iq: 130
		confirmed: true
		language: 'ruby'
		uploads: 4
	]
	
	teams = [
		name: 'zero cool'
	,
		name: 'acid burn'
	,
		name: 'cereal killer'
	,
		name: 'lord nikon'
	]

	class Game
		constructor: (@teams) ->
		zipPath: 'C:\\zippath\\file1.zip'
		getWinner: -> @teams[0]
		getLoser: -> @teams[1]

	tournaments = [
		date: '2014/06/05',
		matches: [
			games: [
				new Game([teams[0],teams[1]])
			]
			winner: 'bimbo'
			competitor1:
				id: '5390893886b1fa782422f5d7'
				name: 'zwand'
			competitor2:
				id: '5390b83b1df5ba843a768a6d'
				name: 'bimbo'
		],
		games_per_match: 6,
		scoreboard: [
			name: 'bimbo',
			wins: 28,
			losses: 2,
			gravatar: 'http://www.gravatar.com/avatar/73ebc7d00584295ee7d137a6a973a0af?s=350&d=mm'
			minionsKilled: 41
			greaterMinionsBuilt: 32
			lesserMinionsBuilt: 23
			foxesBuilt: 51
			tanksBuilt: 72
			gruntsBuilt: 121
			archersBuilt: 11
			seersBuilt: 9
			minersBuilt: 141
			goldMined: 121039
		,
			name: 'newtwo',
			wins: 26,
			losses: 4,
			gravatar: 'http://www.gravatar.com/avatar/f503acea48a6784bceb33120ec4995c9?s=350&d=mm'
			minionsKilled: 41
			greaterMinionsBuilt: 32
			lesserMinionsBuilt: 23
			foxesBuilt: 51
			tanksBuilt: 72
			gruntsBuilt: 121
			archersBuilt: 11
			seersBuilt: 9
			minersBuilt: 141
			goldMined: 86352
		,
			name: 'zwand',
			wins: 9,
			losses: 21,
			gravatar: 'http://www.gravatar.com/avatar/775724a0b43a97b6c42a4b6861eceb65?s=350&d=mm'
			minionsKilled: 41
			greaterMinionsBuilt: 32
			lesserMinionsBuilt: 23
			foxesBuilt: 51
			tanksBuilt: 72
			gruntsBuilt: 121
			archersBuilt: 11
			seersBuilt: 9
			minersBuilt: 141
			goldMined: 2644
		,
			name: 'bbob',
			wins: 9,
			losses: 21,
			gravatar: 'http://www.gravatar.com/avatar/5e828f803b832bf4d8527b9140146275?s=350&d=mm'
			minionsKilled: 41
			greaterMinionsBuilt: 32
			lesserMinionsBuilt: 23
			foxesBuilt: 51
			tanksBuilt: 72
			gruntsBuilt: 121
			archersBuilt: 11
			seersBuilt: 9
			minersBuilt: 141
			goldMined: 238356
		,
			name: 'johnnyd',
			wins: 9,
			losses: 21,
			gravatar: 'http://www.gravatar.com/avatar/361f4923dd2d84364ba8502a508dd07f?s=350&d=mm'
			minionsKilled: 41
			greaterMinionsBuilt: 32
			lesserMinionsBuilt: 23
			foxesBuilt: 51
			tanksBuilt: 72
			gruntsBuilt: 121
			archersBuilt: 11
			seersBuilt: 9
			minersBuilt: 141
			goldMined: 34573
		,
			name: 'new',
			wins: 9,
			losses: 21,
			gravatar: 'http://www.gravatar.com/avatar/d85202b32ef40a1387e461501dd31c85?s=350&d=mm'
			minionsKilled: 41
			greaterMinionsBuilt: 32
			lesserMinionsBuilt: 23
			foxesBuilt: 51
			tanksBuilt: 72
			gruntsBuilt: 121
			archersBuilt: 11
			seersBuilt: 9
			minersBuilt: 141
			goldMined: 5768
		],
		standings: 'TOURNAMENT RESULTS:\r\n--------------\r\nbimbo: 28 - 2\r\nnewtwo: 26 - 4\r\nzwand: 9 - 21\r\nbbob: 9 - 21\r\njohnnyd: 9 - 21\r\nnew: 9 - 21\r\n',
		folder: 'matches\\tournaments\\2014\\June\\5\\tourney 6'
	]

	#-------------
	# Test Helpers
	#-------------
	addCompetitors = ->
		Q.all [
			Mongo.addCompetitor competitors[0]
			Mongo.addCompetitor competitors[1]
			Mongo.addCompetitor competitors[2]
		]

	removeCompetitors = ->
		Q.all [
			Mongo.removeCompetitor {name:competitors[0].name}
			Mongo.removeCompetitor {name:competitors[1].name}
			Mongo.removeCompetitor {name:competitors[2].name}
		]

	addTournaments = ->
		Q.all [
			Mongo.addTournament tournaments[0]
		]

	removeTournaments = ->
		Q.all [
			Mongo.removeTournament {name:tournaments[0].name}
		]

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Standings, 'addTournament').andReturn()

	#-----------
	# Unit Tests
	#-----------
	describe 'competitor functions', ->
		# TODO: see about getting beforeEach to work asynchronously
		# beforeEach () ->
		# 	Mongo.addCompetitor competitor for competitor in competitors

		# afterEach () ->
		# 	Mongo.removeCompetitor {name:competitor.name} for competitor in competitors

		it 'can run addCompetitor correctly', (done) ->
			comp = competitors[0]
			Mongo.addCompetitor(comp)
				.then (result) ->
					expect(result.name).toBe(comp.name)
					Mongo.removeCompetitor {name:comp.name}
				.done ->
					done()	

		it 'returns competitor on addCompetitor', (done) ->
			Mongo.addCompetitor(competitors[0])	
				.then (competitor) ->
					expect(competitor.name).toBe(competitors[0].name)
				.catch () ->
					TestHelpers.fail()
				.done () ->
					Mongo.removeCompetitor {name:competitors[0].name}
					done()

		it 'can query competitors table via getCompetitor', (done) ->
			comp = competitors[0]
			Mongo.addCompetitor(comp)
				.then ->
					Mongo.getCompetitor {age: comp.age}
				.then (result) ->
					expect(result.name).toBe(comp.name)
					removeCompetitors()
				.done ->
					done()	

		it 'returns an array from getCompetitors', (done) ->
			addCompetitors()
				.then ->
					Mongo.getCompetitors({iq: { $lt: 101 }}, {name: 1, iq: 1})
				.then (result) ->
					expect(result.length).toBe(2)
					expect(result[0].iq).toBe(competitors[0].iq)
					expect(result[1].iq).toBe(competitors[1].iq)
					expect(result[0].age).toBeFalsy()
					expect(result[1].age).toBeFalsy()
					removeCompetitors()
				.done ->
					done()

		it 'returns the last competitor port + 1 for getNewCompetitorPort', (done) ->
			addCompetitors()
				.then ->
					Mongo.getNewCompetitorPort()
				.then (result) ->
					expect(result).toBe(competitors[0].port + 1)
					removeCompetitors()
				.done ->
					done()

		it 'returns the right count for getCompetitorAggregate', (done) ->
			addCompetitors()
				.then ->
					aggregate = [
						{$group: _id: "", uploads: { $sum: "$uploads" }},
						{$project: _id: 0, uploads: "$uploads"}
					]
					Mongo.getCompetitorAggregate(aggregate)
				.then (result) ->
					expect(result.uploads).toBe(5)
					removeCompetitors()
				.done ->
					done()

		it 'performs correct update when calling findAndModifyCompetitor', (done) ->
			name = competitors[1].name
			modified = name + ' modded'
			addCompetitors()
				.then ->
					Mongo.findAndModifyCompetitor {name: name}, { $inc: { uploads: 1 } }
				.then (result) ->
					expect(result.uploads).toBe(1)
					removeCompetitors()
				.done ->
					done()

	describe 'tournament functions', ->
		it 'returns the right count for getRoundRobinTournaments', (done) ->
			addTournaments()
				.then ->
					Mongo.getRoundRobinTournaments()
				.then (result) ->
					expect(result.length).toBeGreaterThan(0)
					removeTournaments()
				.done ->
					done()

		it 'can successfully run addRoundRobinTournament', (done) ->
			tourney = tournaments[0]
			Mongo.addRoundRobinTournament(tourney, tourney.scoreboard, tourney.standings)
				.then (result) ->
					# console.log JSON.stringify(result)
					expect(result.matches).toBeTruthy()
					expect(result.matches[0].games).toBeTruthy()
					expect(result.matches[0].games[0].loser).toBeTruthy()
					removeTournaments()
				.then ->
					done()

		it 'returns tournament for getRoundRobinTournament', (done) ->
			addTournaments()
				.then ->
					Mongo.getRoundRobinTournaments()
				.then (tournaments) ->
					tournamentId = tournaments[0]._id
					Mongo.getRoundRobinTournament(tournamentId)
				.then (tournament) ->
					expect(tournament).not.toBeNull()
					expect(tournament.matches).toBeDefined()
					expect(tournament.matches.length).toBe(1)
				.done ->
					removeTournaments()
					done()

		it 'should create dbScoreboard for addRoundRobinTournament', (done) ->
			tourney = tournaments[0]
			Mongo.addRoundRobinTournament(tourney, tourney.scoreboard, tourney.standings)
				.then (result) ->
					expect(result.scoreboard[0].gold_mined).toBe(121039)
					removeTournaments()
				.done ->
					done()