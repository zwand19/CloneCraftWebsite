Base = require '../../server/entities/base'
Board = require '../../server/entities/board'
Constants = require '../../server/settings/constants'
Game = require('../../server/game/game').Game
GameStatus = require '../../server/game/gameStatus'
Helpers = require '../../server/helpers'
Minion = require '../../server/entities/minion'
Resource = require '../../server/entities/resource'
Team = require '../../server/entities/team'

describe 'Game Status', () ->
	game = {}
	team1 = {}
	team2 = {}

	beforeEach () ->
		team1 = new Team(1)
		team2 = new Team(2)
		game = new Game(1, [team1, team2])
		removeAllResources()

	removeAllResources = () ->
		len = game.board.resources.length
		for i in [0...len]
			resource = game.board.resources.pop()
			game.board.setObjectAt(resource.x, resource.y, null)

	describe 'Own team', () ->
		it 'should store the teams base', () ->
			status = new GameStatus(team1, game, true)
			expect(status.base.x).toBe(team1.base.x)
			expect(status.base.y).toBe(team1.base.y)
		it 'should store the list of own minions', () ->
			minion1 = new Minion(1, 1, 1, 1, 1, 1, 1)
			minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)
			minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
			game.board.placeMinion(team1, minion1, 0, 0)
			game.board.placeMinion(team1, minion2, 0, 1)
			game.board.placeMinion(team2, minion3, 1, 0)
			status = new GameStatus(team1, game, true)
			expect(status.minions.length).toBe(2)
			expect(status.minions[0].id).toBe(minion1.id)
			expect(status.minions[1].id).toBe(minion2.id)
	describe 'vision', () ->
		it 'should return minions in sight', () ->
			minion1 = new Minion(1, 1, 1, 1, 1, 1, 1)
			minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)
			minion3 = new Minion(2, 1, 1, 1, 1, 1, 1)
			game.board.placeMinion(team1, minion1, 0, 0)
			game.board.placeMinion(team1, minion2, 0, 1)
			game.board.placeMinion(team2, minion3, 1, 0)
			status = new GameStatus(team2, game, true)
			expect(status.vision.minions.length).toBe(2)
			expect(status.vision.minions[0].id).toBe(minion1.id)
			expect(status.vision.minions[1].id).toBe(minion2.id)
		it 'should store all resources in sight', () ->
			game.board.placeMinion(team1, new Minion(1, 1, 1, 1, 1, 1, 1), 0, 0)
			game.board.placeResource(1, 0)
			game.board.placeResource(0, 1)
			status = new GameStatus(team1, game, true)
			expect(status.vision.resources.length).toBe(2)
		it 'should store all bases in sight', () ->
			minion = new Minion(1, 1, 1, 1, 1, 1, 1)
			game.board.placeMinion(team1, minion, game.teams[1].base.x - 1, game.teams[1].base.y)
			status = new GameStatus(team1, game, true)
			expect(status.vision.bases.length).toBe(1)
	describe 'board', () ->
		it 'should store the board size', () ->
			status = new GameStatus(team1, game, true)
			expectedBoardSize = game.board.width
			expect(status.board.w).toBe(expectedBoardSize)