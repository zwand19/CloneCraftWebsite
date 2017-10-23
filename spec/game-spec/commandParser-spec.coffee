Base = require '../../server/entities/base'
Board = require '../../server/entities/board'
CommandParser = require '../../server/game/commandParser'
Constants = require '../../server/settings/constants'
Minion = require '../../server/entities/minion'
Resource = require '../../server/entities/resource'
Team = require '../../server/entities/team'

describe 'CommandParser', () ->
	team = {}
	board = {}
	parser = {}
	command = {}
	params = {}
	minion = {}
	minion2 = {}
	resource = {}
	
	beforeEach () -> 
		team = new Team(1)
		board = new Board(1, 30)
		minion = new Minion(1, 1, 1, 1, 1, 1, 1)
		minion.carrying = 10
		minion.turnOver()
		minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)
		minion2.turnOver()
		board.placeBase(team, 2, 2)
		board.placeMinion(team, minion, 1, 1)
		board.placeMinion(team, minion2, 1, 0)
		board.placeResource(0, 1)
		parser = new CommandParser(team, board)


	paramsAreInvalid = (command) ->
		expect(parser.paramsAreValid(command)).toBeFalsy()
	paramsAreValid = (command) ->
		expect(parser.paramsAreValid(command)).toBeTruthy()
	parseIsInvalid = (command) ->
		expect(parser.parse(command)).toBeFalsy()
	parseIsValid = (command) ->
		expect(parser.parse(command)).toBeTruthy()

	describe 'Constructor', () ->
	
	describe 'paramsAreValid', () ->
		it 'should return false on invalid params', () ->
			paramsAreInvalid({ commandName: Constants.commands.attack, minionId: 1, params: null })
			paramsAreInvalid({ commandName: Constants.commands.attack, minionId: 1, params: undefined })
		describe 'attack command', () ->
			beforeEach () ->
				params = { x: 1, y: 1 }
				command = { commandName: Constants.commands.attack, minionId: 1, params: params }
			it 'should return false on invalid x', () ->
				params.x = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid y', () ->
				params.y = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid minion id', () ->
				command = { commandName: Constants.commands.handOff, minionId: undefined, params: { x: 1, y: 1 } }
		describe 'build lesser minion command', () ->
			beforeEach () ->
				params = { x: 1, y: 1, stats: {} }
				command = { commandName: Constants.commands.buildLesserMinion, minionId: 1, params: params }
			it 'should return false on invalid x', () ->
				params.x = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid y', () ->
				params.y = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid stats', () ->
				params.stats = undefined
				paramsAreInvalid(command)
		describe 'build greater minion command', () ->
			beforeEach () ->
				params = { x: 1, y: 1, stats: {} }
				command = { commandName: Constants.commands.buildGreaterMinion, minionId: 1, params: params }
			it 'should return false on invalid x', () ->
				params.x = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid y', () ->
				params.y = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid stats', () ->
				params.stats = undefined
				paramsAreInvalid(command)
		describe 'hand off command', () ->
			it 'should return false on invalid minionId', () ->
				command = { commandName: Constants.commands.handOff, minionId: undefined, params: { minionId: 1 } }
			it 'should return false on invalid params minionId', () ->
				command = { commandName: Constants.commands.handOff, minionId: 1, params: { } }
		describe 'mine resources command', () ->
			beforeEach () ->
				params = { x: 1, y: 1 }
				minion.carrying = 0
				command = { commandName: Constants.commands.mineResource, minionId: 1, params: params }
			it 'should return false on invalid x', () ->
				params.x = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid y', () ->
				params.y = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid minionId', () ->
				command = { commandName: Constants.commands.mineResource, minionId: undefined, params: params }
		describe 'move minion command', () ->
			beforeEach () ->
				params = { x: 1, y: 1 }
				command = { commandName: Constants.commands.moveMinion, minionId: 1, params: params }
			it 'should return false on invalid x', () ->
				params.x = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid y', () ->
				params.y = undefined
				paramsAreInvalid(command)
			it 'should return false on invalid minionId', () ->
				command = { commandName: Constants.commands.moveMinion, minionId: undefined, params: params }

	describe 'parseCommand', () ->
		it 'should return true on a valid command', () ->
			parseIsValid({ commandName: Constants.commands.moveMinion, minionId: 1, params: { direction: 'E' }})
		describe 'attack commands', () ->
			it 'should return true on a valid command', () ->
				parseIsValid({ commandName: Constants.commands.attack, minionId: 1, params: { x: minion2.x, y: minion2.y }})
			it 'should return false on a invalid id', () ->
				parseIsInvalid({ commandName: Constants.commands.attack, minionId: 100, params: { x: minion2.x, y: minion2.y }})
			it 'should return false on a invalid coordinates', () ->
				parseIsInvalid({ commandName: Constants.commands.attack, minionId: 1, params: { x: 0, y: board.width }})
		describe 'build lesser minion commands', () ->
			it 'should return true on a valid command', () ->
				parseIsValid({ commandName: Constants.commands.buildLesserMinion, minionId: null, params: { x: 2, y: 1, stats: { d: 1, r: 1, s: 1, h: 1, v: 1, m: 1 } }})
			it 'should return false on a invalid stats', () ->
				parseIsInvalid({ commandName: Constants.commands.buildLesserMinion, minionId: null, params: { x: 2, y: 1, stats: { d: 0, r: 1, s: 1, h: 1, v: 1, m: 1 } }})
			it 'should return false on a invalid coordinates', () ->
				parseIsInvalid({ commandName: Constants.commands.buildLesserMinion, minionId: null, params: { stats: { d: 1, r: 1, s: 1, h: 1, v: 1, m: 1 } }})
		describe 'build greater minion commands', () ->
			it 'should return true on a valid command', () ->
				parseIsValid({ commandName: Constants.commands.buildGreaterMinion, minionId: null, params: { x: 2, y: 1, stats: { d: 1, r: 1, s: 1, h: 1, v: 1, m: 1 } }})
			it 'should return false on a invalid stats', () ->
				parseIsInvalid({ commandName: Constants.commands.buildGreaterMinion, minionId: null, params: { x: 2, y: 1, stats: { d: 0, r: 1, s: 1, h: 1, v: 1, m: 1 } }})
			it 'should return false on a invalid coordinates', () ->
				parseIsInvalid({ commandName: Constants.commands.buildGreaterMinion, minionId: null, params: { stats: { d: 1, r: 1, s: 1, h: 1, v: 1, m: 1 } }})
		describe 'move commands', () ->
			it 'should return true on a valid command', () ->
				parseIsValid({ commandName: Constants.commands.moveMinion, minionId: 1, params: { direction: 'S' }})
			it 'should return false on a invalid id', () ->
				parseIsInvalid({ commandName: Constants.commands.moveMinion, minionId: 100, params: { direction: 'S' }})
			it 'should return false on a invalid direction', () ->
				parseIsInvalid({ commandName: Constants.commands.moveMinion, minionId: 1, params: { direction: 'asd' }})
		describe 'hand off commands', () ->
			it 'should return true on a valid command', () ->
				parseIsValid({ commandName: Constants.commands.handOff, minionId: 1, params: { minionId: 2 }})
			it 'should return false on a invalid id', () ->
				parseIsInvalid({ commandName: Constants.commands.handOff, minionId: 100, params: { minionId: 2 }})
			it 'should return false on a invalid hand off id', () ->
				parseIsInvalid({ commandName: Constants.commands.handOff, minionId: 1, params: { minionId: 3 }})
		describe 'mine commands', () ->
			it 'should return true on a valid command', () ->
				minion.carrying = 0
				parseIsValid({ commandName: Constants.commands.mineResource, minionId: 1, params: { x: 0, y: 1 }})
			it 'should return false on a invalid id', () ->
				minion.carrying = 0
				parseIsInvalid({ commandName: Constants.commands.mineResource, minionId: 100, params: { x: 0, y: 1 }})
			it 'should return false on a invalid coordinates', () ->
				minion.carrying = 0
				parseIsInvalid({ commandName: Constants.commands.mineResource, minionId: 1, params: { x: 1, y: 0 }})