Base = require '../../server/entities/base'
Board = require '../../server/entities/board'
Game = require('../../server/game/game').Game
GameRules = require '../../server/settings/gameRules'
Helpers = require '../../server/helpers'
Resource = require '../../server/entities/resource'
Team = require '../../server/entities/team'

describe 'Game', ->
	game = {}
	team1 = {}
	team2 = {}
	
	beforeEach -> 
		team1 = new Team(1)
		team2 = new Team(2)

	basesAreSameDistanceFromCenter = (teams, center) ->
		distanceToCenter = teams[0].base.distanceFromBase(center, center)
		for i in [1...teams.length]
			distanceFromOtherBaseToCenter = teams[i].base.distanceFromBase(center, center)
			differenceInDistance = Math.abs(distanceFromOtherBaseToCenter - distanceToCenter)
			#expect(differenceInDistance <= 2).toBeTruthy()

	basesAreSpreadOut = (teams) ->
		distanceBetweenBases = Helpers.distanceBetween(teams[0].base, teams[1].base)
		for i in [1...teams.length - 1]
			distanceBetweenOtherBases = Helpers.distanceBetween(teams[i].base, teams[i + 1].base)
			differenceInDistance = distanceBetweenOtherBases - distanceBetweenBases
			#expect(differenceInDistance <= 2).toBeTruthy()
		
		distanceBetweenOtherBases = Helpers.distanceBetween(teams[0].base, teams[teams.length - 1].base)
		differenceInDistance = Math.abs(distanceBetweenOtherBases - distanceBetweenBases)
		#expect(differenceInDistance <= 2).toBeTruthy()

	removeAllResources = ->
		len = game.board.resources.length
		for i in [0...len]
			resource = game.board.resources.pop()
			game.board.setObjectAt(resource.x, resource.y, null)
				

	describe 'Constructor', ->
		it 'should set current turn to the first team', ->
			game = new Game(1, [team1, team2])
			expect(game.currentTeam).toBe(team1)
			expect(game.currentTeam).toNotBe(team2)
		it 'should initialize round to 1', ->
			expect(new Game(1, [team1, team2]).round).toBe(1)
		it 'should initialize the number of remaining teams', ->
			expect(new Game(1, [team1, team2]).numTeamsRemaining).toBe(2)

	describe 'executeCommands', ->
		it 'should increment turn once commands are executed', ->
			game = new Game 1, [team1, team2]
			game.executeCommands []
			expect(game.currentTeam).toBe team2
		it 'should end the game if there is only one team remaining', ->
			game = new Game 1, [team1, team2]
			team2.baseKilled()
			game.executeCommands []
			#TODO: add test that game is over

	describe 'incrementTurn', ->
		it 'should set a new current team', ->
			game = new Game 1, [team1, team2]
			game.incrementTurn()
			expect(game.currentTeam).toBe team2
		it 'should reset current team to the first team after a round', ->
			game = new Game 1, [team1, team2]
			game.incrementTurn()
			game.incrementTurn()
			expect(game.currentTeam).toBe team1
		it 'should increase the round after a round', ->
			game = new Game(1, [team1, team2])
			game.incrementTurn()
			game.incrementTurn()
			expect(game.round).toBe 2
		it 'should increase the round twice after two rounds', ->
			game = new Game 1, [team1, team2]
			game.incrementTurn()
			game.incrementTurn()
			game.incrementTurn()
			game.incrementTurn()
			expect(game.round).toBe 3

	describe 'makeBoard', ->
		describe 'standard map', ->
			beforeEach ->
				GameRules.map = 'standard'
				game = new Game(1, [team1, team2])

			it 'should make a board wider than it is tall', ->
				expect(game.board.width).toBeGreaterThan game.board.height
			it 'should make bases the same distance from the edges', ->
				expect(game.board.bases[0].x).toBe(game.board.width - 1 - (game.board.bases[1].x + GameRules.base.size - 1))
			it 'should make bases at the same y', ->
				expect(game.board.bases[0].y).toBe(game.board.bases[1].y)
			it 'should vertically center the bases', ->
				distanceToCenter = GameRules.maps.standard.height / 2 - (game.board.bases[0].y + GameRules.base.size / 2)
				expect(Math.abs(distanceToCenter) <= .5).toBeTruthy()
			it 'should create the correct amount of resources every time', ->
				for i in [0...30]
					team1 = new Team(1)
					team2 = new Team(2)
					game = new Game 1, [team1, team2]
					expect(game.board.resources.length).toBe GameRules.maps.standard.resourcesPerTeam * 2

		describe 'square map', ->
			beforeEach ->
				GameRules.map = 'square'
				game = new Game(1, [team1, team2])

			it 'should make a square board', ->
				expect(game.board.width).toBeGreaterThan 0
				expect(game.board.width).toBe game.board.height
			it 'should create bases in random corners', ->
				base1Corners = [false, false, false, false]
				base2Corners = [false, false, false, false]
				for i in [0...30]
					team1 = new Team(1)
					team2 = new Team(2)
					game = new Game 1, [team1, team2]
					if game.board.bases[0].x < game.board.width / 2 and game.board.bases[0].y < game.board.height / 2
						base1Corners[0] = true
					if game.board.bases[0].x > game.board.width / 2 and game.board.bases[0].y < game.board.height / 2
						base1Corners[1] = true
					if game.board.bases[0].x > game.board.width / 2 and game.board.bases[0].y > game.board.height / 2
						base1Corners[2] = true
					if game.board.bases[0].x < game.board.width / 2 and game.board.bases[0].y > game.board.height / 2
						base1Corners[3] = true
					if game.board.bases[1].x < game.board.width / 2 and game.board.bases[1].y < game.board.height / 2
						base2Corners[0] = true
					if game.board.bases[1].x > game.board.width / 2 and game.board.bases[1].y < game.board.height / 2
						base2Corners[1] = true
					if game.board.bases[1].x > game.board.width / 2 and game.board.bases[1].y > game.board.height / 2
						base2Corners[2] = true
					if game.board.bases[1].x < game.board.width / 2 and game.board.bases[1].y > game.board.height / 2
						base2Corners[3] = true
				expect(base1Corners[0]).toBeTruthy()
				expect(base1Corners[1]).toBeTruthy()
				expect(base1Corners[2]).toBeTruthy()
				expect(base1Corners[3]).toBeTruthy()
				expect(base2Corners[0]).toBeTruthy()
				expect(base2Corners[1]).toBeTruthy()
				expect(base2Corners[2]).toBeTruthy()
				expect(base2Corners[3]).toBeTruthy()
			it 'should create the correct amount of resources every time', ->
				for i in [0...30]
					team1 = new Team(1)
					team2 = new Team(2)
					game = new Game 1, [team1, team2]
					expect(game.board.resources.length).toBe GameRules.maps.square.resourcesPerQuadrant * 4
