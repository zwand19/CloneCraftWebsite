Base = require '../../server/entities/base'
Board = require '../../server/entities/board'
Constants = require '../../server/settings/constants'
GameRules = require '../../server/settings/gameRules'
Minion = require '../../server/entities/minion'
Resource = require '../../server/entities/resource'
Team = require '../../server/entities/team'

describe 'Board', () ->
	board = {}
	minion = {}
	minion2 = {}
	team = {}
	team2 = {}
	base = {}
	resource = {}
	
	beforeEach () -> 
		reset()
		
	cellIsOccupiedOrInvalid = (x, y) ->
		expect(board.cellIsUnoccupiedAndValid(x, y)).toBeFalsy()
	cellIsUnoccupiedAndValid = (x, y) ->
		expect(board.cellIsUnoccupiedAndValid(x, y)).toBeTruthy()
	cellIsMoveable = (x, y, team) ->
		expect(board.cellIsMoveable(x, y, team)).toBeTruthy()
	cellIsNotMoveable = (x, y, team) ->
		expect(board.cellIsMoveable(x, y, team)).toBeFalsy()
	executeBuildFails = (minionName, x, y, stats) ->
		minionName = Constants.building.lesserMinionName if minionName is undefined
		x = 1 if x is undefined
		y = 1 if y is undefined
		stats = {d: 1, s: 1, h: 1, m: 1, v: 1, r: 1} if stats is undefined
		expect(board.executeBuild(team, minionName, x, y, stats)).toBeFalsy()
	executeBuildPasses = (minionName, x, y, stats) ->
		minionName = Constants.building.lesserMinionName if minionName is undefined
		x = 1 if x is undefined
		y = 1 if y is undefined
		stats = {d: 1, s: 1, h: 1, m: 1, v: 1, r: 1} if stats is undefined
		expect(board.executeBuild(team, minionName, x, y, stats)).toBeTruthy()
	executeHandOffFails = (id1, id2) ->
		id1 = 1 if id1 is undefined
		id2 = 2 if id2 is undefined
		expect(board.executeHandOff(team, id1, id2)).toBeFalsy()
	executeHandOffPasses = (id1, id2) ->
		id1 = 1 if id1 is undefined
		id2 = 2 if id2 is undefined
		expect(board.executeHandOff(team, id1, id2)).toBeTruthy()
	mineResourceFails = (x, y) ->
		x = 1 if x is undefined
		y = 1 if y is undefined
		expect(board.mineResource(team, 1, x, y)).toBeFalsy()
	mineResourcePasses = (x, y) ->
		x = 1 if x is undefined
		y = 1 if y is undefined
		expect(board.mineResource(team, 1, x, y)).toBeTruthy()
	objectOnBoardIsNull = (x, y) ->
		expect(board.getObjectAt(x,y)).toBeNull()
	objectOnBoardIsUndefined = (x, y) ->
		expect(board.getObjectAt(x,y)).toBe()
	placeBase = (x, y) ->
		x = 2 if x is undefined
		y = 1 if y is undefined
		board.placeBase(team, x, y)
	placeBaseFails = (x, y) ->
		expect(placeBase(x, y)).toBeFalsy()
	placeBasePasses = (x, y) ->
		expect(placeBase(x, y)).toBeTruthy()
	placeMinion = (x, y) ->
		x = 1 if x is undefined
		y = 1 if y is undefined
		board.placeMinion(team, minion, x, y)
	placeMinionFails = (x, y) ->
		expect(placeMinion(x, y)).toBeFalsy()
	placeMinionPasses = (x, y) ->
		expect(placeMinion(x, y)).toBeTruthy()
	placeMinions = () ->
		board.placeMinion(team, minion, 1, 1)
		board.placeMinion(team, minion2, 2, 1)
	placeMinionsDifferentTeams = () ->
		board.placeMinion(team, minion, 1, 1)
		board.placeMinion(team2, minion2, 2, 1)
	placeResource = (x, y) ->
		x = 1 if x is undefined
		y = 1 if y is undefined
		board.placeResource(x, y)
	placeResourceFails = (x, y) ->
		expect(placeResource(x, y)).toBeFalsy()
	placeResourcePasses = (x, y) ->
		expect(placeResource(x, y)).toBeTruthy()
	reset = () ->
		board = new Board(1, 50)
		team = new Team(1)
		team2 = new Team(2)
		minion = new Minion(1, 1, 1, 1, 1, 1, 1)
		minion.turnOver()
		minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)
		minion2.turnOver()
	teamHasMinion = () ->
		expect(board.minions.length).toBe(1)
		expect(team.minions[minion.id]).toBe(minion)
	teamHasMinions = () ->
		expect(board.minions.length).toBe(2)
		expect(team.minions[minion.id]).toBe(minion)
		expect(team.minions[minion2.id]).toBe(minion2)

	describe 'Constructor', () ->
		it 'should initialize a square grid', () ->
			board = new Board(1, 5)
			objectOnBoardIsNull(0, 0)
			objectOnBoardIsNull(0, 4)
			objectOnBoardIsNull(4, 4)
			objectOnBoardIsNull(2, 2)
			objectOnBoardIsNull(4, 0)
			objectOnBoardIsUndefined(5, 0)
			objectOnBoardIsUndefined(0, 5)
			objectOnBoardIsUndefined(5, 5)
		it 'should initialize empty arrays of objects', () ->
			expect(board.minions.length).toBe(0)
			expect(board.bases.length).toBe(0)
			expect(board.resources.length).toBe(0)

	describe 'cellIsMoveable', () ->
		it 'should return false for invalid coordinates', () ->
			placeBase()
			cellIsNotMoveable(-1, 1, team)
			cellIsNotMoveable(1, -1, team)
			cellIsNotMoveable(1, board.height, team)
			cellIsNotMoveable(board.width, 1, team)
		it 'should return true for valid coordinates', () ->
			cellIsMoveable(3, 3, team)
			cellIsMoveable(0, 0, team)
			cellIsMoveable(board.width - 1, board.height - 1, team)
			cellIsMoveable(board.width - 1, 3, team)
			cellIsMoveable(3, board.height - 1, team)
		it 'should return true on own base', () ->
			placeBase(1, 1)
			cellIsMoveable(1, 1, team)
			cellIsMoveable(2, 2, team)
		it 'should return false on other teams base', () ->
			placeBase(1, 1)
			board.placeBase(10, 1, team2)
			cellIsNotMoveable(1, 1, team2)
			cellIsNotMoveable(2, 2, team2)
		it 'should return false on a minion', () ->
			placeBase(1, 1)
			placeMinion(0, 1)
			cellIsNotMoveable(0, 1, team)
		it 'should return true on a resource', () ->
			placeBase(5, 5)
			placeResourcePasses(1, 1)
			placeResourcePasses(2, 2)
			cellIsMoveable(1, 1, team)
			cellIsMoveable(2, 2, team)

	describe 'cellIsUnoccupiedAndValid', () ->
		it 'should return false for invalid coordinates', () ->
			cellIsOccupiedOrInvalid(-1, 1)
			cellIsOccupiedOrInvalid(1, -1)
			cellIsOccupiedOrInvalid(1, board.height)
			cellIsOccupiedOrInvalid(board.width, 1)
		it 'should return true for valid coordinates', () ->
			cellIsUnoccupiedAndValid(3, 3)
			cellIsUnoccupiedAndValid(0, 0)
			cellIsUnoccupiedAndValid(board.width - 1, board.height - 1)
			cellIsUnoccupiedAndValid(board.width - 1, 3)
			cellIsUnoccupiedAndValid(3, board.height - 1)
		it 'should return false when a base is occupying the cell', () ->
			board.placeBase(team, 1, 1)
			cellIsOccupiedOrInvalid(1, 1)
			cellIsOccupiedOrInvalid(GameRules.base.size, GameRules.base.size)
		it 'should return true when a base is occupying a different cell', () ->
			board.placeBase(team, 1, 1)
			cellIsUnoccupiedAndValid(0, 0)
			cellIsUnoccupiedAndValid(4, 0)

	describe 'executeAttack', () ->
		describe 'parameter validation', () ->
			it 'should return false when team is not valid', () ->
				placeMinions()
				expect(board.executeAttack(null, minion.id, 1, 1)).toBeFalsy()
				expect(board.executeAttack(undefined, minion.id, 1, 1)).toBeFalsy()
				expect(board.executeAttack(new Base(1, 1, 1), minion.id, 1, 1)).toBeFalsy()
			it 'should return false when minion is not on board', () ->
				board.placeMinion(team, minion2)
				expect(board.executeAttack(team, minion.id, minion2.x, minion2.y)).toBeFalsy()
			it 'should return false with wrong minion id', () ->
				placeMinions()
				expect(board.executeAttack(team, 3, minion2.x, minion2.y)).toBeFalsy()
			it 'should return false with invalid coordinates', () ->
				placeMinionsDifferentTeams()
				expect(board.executeAttack(team, minion.id, minion2.x, -1)).toBeFalsy()
			it 'should return true when attacked', () ->
				placeMinionsDifferentTeams()
				expect(board.executeAttack(team, minion.id, minion2.x, minion2.y)).toBeTruthy()
		describe 'removing killed minions', () ->
			it 'should remove killed minions from the team', () ->
				placeMinionsDifferentTeams()
				minion2.health = 1
				board.executeAttack(team, minion.id, minion2.x, minion2.y)
				expect(team2.getMinion(minion2.id)).toBe()
			it 'should reset the cell of the killed minion', () ->
				placeMinionsDifferentTeams()
				minion2.health = 1
				x = minion2.x
				y = minion2.y
				board.executeAttack(team, minion.id, minion2.x, minion2.y)
				expect(board.getObjectAt(x, y)).toBeNull()
			it 'should not remove damaged minions from the team', () ->
				placeMinionsDifferentTeams()
				minion2.health = minion.damage + 1
				board.executeAttack(team, minion.id, minion2.x, minion2.y)
				expect(team2.getMinion(minion2.id)).toBe(minion2)
			it 'should remove killed minions from the boards list of minions', () ->
				placeMinionsDifferentTeams()
				minion.health = 1
				board.executeAttack(team2, minion2.id, minion.x, minion.y)
				expect(board.minions.length).toBe(1)
				expect(board.minions[0]).toBe(minion2)
			it 'should not remove damaged minions from the boards list of minions', () ->
				placeMinionsDifferentTeams()
				minion.health = minion2.damage + 1
				board.executeAttack(team2, minion2.id, minion.x, minion.y)
				expect(board.minions.length).toBe(2)
				expect(board.minions[0]).toBe(minion)
				expect(board.minions[1]).toBe(minion2)
			it 'should increase killing teams minions killed stat', () ->
				placeMinionsDifferentTeams()
				minion.health = 1
				board.executeAttack(team2, minion2.id, minion.x, minion.y)
				expect(team2.stats.minionsKilled).toBe(1)
		describe 'killing bases', () ->
			it 'should set the teams base to null', () ->
				placeMinion()
				board.placeBase(team2, 1, 2)
				team2.base.health = 1
				board.executeAttack(team, minion.id, 1, 2)
				expect(team2.base).toBeNull()
			it 'should reset the grid cells to null', () ->
				placeMinion()
				board.placeBase(team2, 1, 2)
				team2.base.health = 1
				board.executeAttack(team, minion.id, 1, 2)
				expect(board.getObjectAt(1, 2)).toBeNull()
				expect(board.getObjectAt(1 + GameRules.base.size, 2)).toBeNull()
				expect(board.getObjectAt(1, 2 + GameRules.base.size)).toBeNull()
				expect(board.getObjectAt(1 + GameRules.base.size, 2 + GameRules.base.size)).toBeNull()
			#it 'should convert all minions to killing team', () ->
			#	team3 = new Team(3)
			#	minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)
			#	minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
			#	minion4 = new Minion(4, 1, 1, 1, 1, 1, 1)
			#	board.placeMinion(team, minion, 2, 1)
			#	board.placeMinion(team2, minion2, 1, 1)
			#	board.placeMinion(team2, minion3, 0, 1)
			#	board.placeMinion(team3, minion4, 1, 0)
			#	board.placeBase(team2, 2, 2)
			#	team2.base.health = 1
			#	board.executeAttack(team, minion.id, 2, 2)
			#	expect(minion.team).toBe(team)
			#	expect(minion2.team).toBe(team)
			#	expect(minion3.team).toBe(team)
			#	expect(minion4.team).toBe(team3)

	describe 'executeBuild', () ->
		describe 'parameter validation', () ->
			it 'should return true on valid parameters', () ->
				placeBase()
				executeBuildPasses()
			it 'should return false on invalid minion name', () ->
				placeBase()
				expect(board.executeBuild(team, '', 1, 1)).toBeFalsy()
				expect(board.executeBuild(team, undefined, 1, 1)).toBeFalsy()
				expect(board.executeBuild(team, null, 1, 1)).toBeFalsy()
				executeBuildFails('hero')
				executeBuildFails('minion name')
				executeBuildFails(Constants.building.lesserMinionName + '.')
			it 'should return false if team is not a team', () ->
				placeBase()
				team = {}
				executeBuildFails(Constants.building.lesserMinionName)
				team = minion
				executeBuildFails(Constants.building.lesserMinionName)
				team = null
				executeBuildFails(Constants.building.lesserMinionName)
				team = undefined
				executeBuildFails(Constants.building.lesserMinionName)
			it 'should return false if team has max minions', () ->
				placeBase()
				for i in [0...GameRules.teamMaxMinions]
					team.addMinion(new Minion(i, 1, 1, 1, 1, 1, 1))
				executeBuildFails()
			it 'should return true if team has max minions and minion dies', () ->
				placeBase()
				for i in [0...GameRules.teamMaxMinions]
					team.addMinion(new Minion(i, 1, 1, 1, 1, 1, 1))
				team.minionKilled(1)
				executeBuildPasses()
		describe 'minion placement', () ->
			it 'should return false on an occupied cell', () ->
				placeMinion()
				placeBase()
				executeBuildFails()
			it 'should return false on an invalid cell west or north', () ->
				placeBase(0, 0)
				executeBuildFails(Constants.building.lesserMinionName, -1, 0)
				executeBuildFails(Constants.building.lesserMinionName, 0, -1)
			it 'should return false on an invalid cell east or south', () ->
				placeBase(board.width - GameRules.base.size, board.height - GameRules.base.size)
				executeBuildFails(Constants.building.lesserMinionName, GameRules.base.size, 0)
				executeBuildFails(Constants.building.lesserMinionName, 0, GameRules.base.size)
			it 'should return false if cell is not next to base', () ->
				placeBase(3, 3)
				executeBuildFails(Constants.building.lesserMinionName, 2, 2)
				executeBuildFails(Constants.building.lesserMinionName, 1, 2)
				executeBuildFails(Constants.building.lesserMinionName, 2, 1)
				executeBuildFails(Constants.building.lesserMinionName, 3 + GameRules.base.size, 3 + GameRules.base.size)
				executeBuildFails(Constants.building.lesserMinionName, 2, 3 + GameRules.base.size)
			it 'should return false if cell is in base', () ->
				placeBase(3, 3)
				executeBuildFails(Constants.building.lesserMinionName, 3, 3)
				executeBuildFails(Constants.building.lesserMinionName, 2 + GameRules.base.size, 3)
				executeBuildFails(Constants.building.lesserMinionName, 3, 2 + GameRules.base.size)
				executeBuildFails(Constants.building.lesserMinionName, 2 + GameRules.base.size, 2 + GameRules.base.size)
			it 'should return false if team does not have base', () ->
				base.team = null
				executeBuildFails()
			it 'should return true next to a minion', () ->
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildPasses(Constants.building.lesserMinionName, 4, 5)
				reset()
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildPasses(Constants.building.lesserMinionName, 6, 5)
				reset()
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildPasses(Constants.building.lesserMinionName, 5, 4)
				reset()
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildPasses(Constants.building.lesserMinionName, 5, 6)
			it 'should return false not next to a minion', () ->
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildFails(Constants.building.lesserMinionName, 4, 4)
				reset()
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildFails(Constants.building.lesserMinionName, 6, 6)
				reset()
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildFails(Constants.building.lesserMinionName, 6, 4)
				reset()
				placeBase(0, 0)
				placeMinion(5, 5)
				executeBuildFails(Constants.building.lesserMinionName, 4, 6)
		describe 'post-build data validation', () ->
			it 'should add the minion to the list of minions', () ->
				placeBase()
				executeBuildPasses()
				expect(board.minions.length).toBe(1)
			it 'should generate unique ids', () ->
				placeBase()
				team.base.gold = 1000
				executeBuildPasses(Constants.building.lesserMinionName, 1, 1)
				team.base.canBuild = true
				executeBuildPasses(Constants.building.lesserMinionName, 1, 2)
				expect(board.minions[0].id).toNotBe(board.minions[1].id)

	describe 'executeHandOff', () ->
		beforeEach ->
			placeBase 5, 5
			
		it 'should fail if team is not team', () ->
			placeMinions()
			team = null
			executeHandOffFails()
		it 'should pass on a valid hand off', () ->
			placeMinions()
			minion.carrying = 10
			executeHandOffPasses()
		it 'should fail on invalid ids', () ->
			placeMinions()
			minion.carrying = 10
			executeHandOffFails(4, minion2.id)
			reset()
			placeMinions()
			minion.carrying = 10
			executeHandOffFails(minion.id, 4)
		it 'should fail on handing off to self', () ->
			placeMinions()
			minion.carrying = 10
			executeHandOffFails(minion.id, minion.id)
		it 'should hand off gold', () ->
			placeMinions()
			minion.carrying = 10
			board.executeHandOff(team, minion.id, minion2.id)
			expect(minion.carrying).toBe(0)
			expect(minion2.carrying).toBe(10)

	describe 'getObjectAt', () ->
		it 'should return undefined with negative coordinates', () ->
			expect(board.getObjectAt(-1,0)).toBe(undefined)
			expect(board.getObjectAt(0,-1)).toBe(undefined)
			expect(board.getObjectAt(-1,-1)).toBe(undefined)
		it 'should return undefined with out of range coordinates', () ->
			expect(board.getObjectAt(board.width,0)).toBe(undefined)
			expect(board.getObjectAt(0,board.height)).toBe(undefined)
			expect(board.getObjectAt(board.width,board.height)).toBe(undefined)
		it 'should return objects with valid coordinates', () ->
			expect(board.getObjectAt(9,0)).toBeDefined()
			expect(board.getObjectAt(0,9)).toBeDefined()
			expect(board.getObjectAt(9,9)).toBeDefined()
			expect(board.getObjectAt(2,2)).toBeDefined()
			expect(board.getObjectAt(0,0)).toBeDefined()
			expect(board.getObjectAt(8,1)).toBeDefined()
		it 'should return set objects', () ->
			board.placeBase(team, 1, 1)
			expect(board.getObjectAt(1, 1) instanceof Base).toBeTruthy()

	describe 'getVision', () ->
		describe 'minions in sight', () ->
			it 'should add all minions in sight of teams minions', () ->
				minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
				minion4 = new Minion(4, 1, 1, 1, 1, 1, 1)
				board.placeMinion(team, minion, 1, 1)
				board.placeMinion(team2, minion2, 1, 2)
				board.placeMinion(team2, minion3, 2, 1)
				board.placeMinion(team2, minion4, 1, 0)
				board.placeBase(team, 21, 21)
				expect(board.getVision(team).minions.length).toBe(3)
			it 'should not include own minions in list', () ->
				minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
				minion4 = new Minion(4, 1, 1, 1, 1, 1, 1)
				board.placeMinion(team, minion, 1, 1)
				board.placeMinion(team, minion2, 1, 2)
				board.placeMinion(team2, minion3, 2, 1)
				board.placeMinion(team2, minion4, 1, 0)
				board.placeBase(team, 21, 21)
				expect(board.getVision(team).minions.length).toBe(2)
			it 'should add all minions in sight of teams base', () ->
				minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
				minion4 = new Minion(4, 1, 1, 1, 1, 1, 1)
				board.placeMinion(team, minion, 1, 1)
				board.placeMinion(team2, minion2, 1, 2)
				board.placeMinion(team2, minion3, 20, 21)
				board.placeMinion(team2, minion4, 20, 22)
				board.placeBase(team, 21, 21)
				expect(board.getVision(team).minions.length).toBe(3)
			it 'should not add minions twice when visible by base and minions', () ->
				minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
				minion4 = new Minion(4, 1, 1, 1, 1, 1, 1)
				board.placeMinion(team, minion, 1, 1)
				board.placeMinion(team2, minion2, 1, 2)
				board.placeMinion(team2, minion3, 1, 3)
				board.placeMinion(team2, minion4, 1, 4)
				board.placeBase(team, 2, 1)
				expect(board.getVision(team).minions.length).toBe(3)
			it 'should return empty if no minions in sight', () ->
				minion3 = new Minion(3, 1, 1, 1, 1, 1, 1)
				minion4 = new Minion(4, 1, 1, 1, 1, 1, 1)
				board.placeMinion(team, minion, 1, 1)
				board.placeMinion(team2, minion2, 31, 2)
				board.placeMinion(team2, minion3, 1, 33)
				board.placeMinion(team2, minion4, 31, 34)
				board.placeBase(team, 2, 1)
				expect(board.getVision(team).minions.length).toBe(0)
		describe 'bases in sight', () ->
			it 'should add all bases in sight', () ->
				board.placeMinion(team, minion, 0, 0)
				board.placeMinion(team, minion2, 31, 31)
				board.placeBase(team, 21, 0)
				board.placeBase(team2, 0, 21)
				board.placeBase(new Team(3), 1, 0)
				board.placeBase(new Team(4), 31, 32)
				expect(board.getVision(team).bases.length).toBe(2)
			it 'should not add own base to sight', () ->
				board.placeMinion(team, minion, 0, 0)
				board.placeMinion(team, minion2, 31, 31)
				board.placeBase(team, 1, 0)
				board.placeBase(team2, 0, 21)
				board.placeBase(new Team(3), 21, 0)
				board.placeBase(new Team(4), 31, 32)
				expect(board.getVision(team).bases.length).toBe(1)
			it 'should add bases even if you cant see top left cell', () ->
				board.placeMinion(team, minion, 0, 0)
				board.placeBase(team, 30, 30)
				board.placeBase(team2, minion.vision, 0)
				expect(board.getVision(team).bases.length).toBe(1)
			it 'should return empty if no bases in sight', () ->
				board.placeMinion(team, minion, 0, 0)
				board.placeBase(team, 30, 30)
				board.placeBase(team2, minion.vision + 1, 0)
				expect(board.getVision(team).bases.length).toBe(0)
		describe 'resources in sight', () ->
			it 'should add all resources in sight', () ->
				board.placeMinion team, minion, 0, 0
				board.placeMinion team, minion2, 31, 31
				board.placeBase team, 21, 21
				board.placeResource 1, 0
				board.placeResource 0, 1
				board.placeResource 30, 31
				board.placeResource 31, 30
				board.placeResource team.base.x + GameRules.base.size + GameRules.resources.minDistanceFromBase - 1, team.base.y
				board.placeResource team.base.x, team.base.y + GameRules.base.size + GameRules.resources.minDistanceFromBase - 1
				expect(board.getVision(team).resources.length).toBe 6
			it 'should not add resources out of sight', () ->
				board.placeMinion team, minion, 0, 0
				board.placeMinion team, minion2, 31, 31
				board.placeBase team, 21, 21
				board.placeResource 0, 1
				board.placeResource 40, 1
				board.placeResource 30, 31
				board.placeResource 41, 42
				board.placeResource team.base.x + GameRules.base.size + GameRules.resources.minDistanceFromBase - 1, team.base.y
				board.placeResource 40, 41
				expect(board.getVision(team).resources.length).toBe 3
			it 'should not add resources that are mined and off of board', () ->
				board.placeMinion team, minion, 0, 0
				board.placeMinion team, minion2, 31, 31
				board.placeBase team, 21, 21
				board.placeResource 1, 0
				board.placeResource 0, 1
				board.placeResource 30, 31
				board.placeResource 31, 30
				board.placeResource team.base.x + GameRules.base.size + GameRules.resources.minDistanceFromBase - 1, team.base.y
				board.placeResource team.base.x, team.base.y + GameRules.base.size + GameRules.resources.minDistanceFromBase - 1
				board.setObjectAt board.resources[5].x, board.resources[5].y, null
				board.resources[5].onBoard = false
				expect(board.getVision(team).resources.length).toBe 5

	describe 'mineResource', () ->
		it 'should return true on valid mine', () ->
			placeMinion(2, 1)
			placeResource()
			mineResourcePasses()
		it 'should return false on invalid team', () ->
			placeMinion(2, 1)
			placeResource()
			team = null
			mineResourceFails()
			team = undefined
			mineResourceFails()
			team = minion2
			mineResourceFails()
		it 'should return false on invalid minion id', () ->
			minion.id = 2
			placeMinion(2, 1)
			placeResource()
			mineResourceFails()
		it 'should return false on invalid resource coordinates', () ->
			placeMinion(2, 1)
			placeResource()
			mineResourceFails(1, 2)

	describe 'moveMinion', () ->
		describe 'parameter validation', () ->
			it 'should return true on valid parameters', () ->
				placeMinion()
				placeBase()
				expect(board.moveMinion(team, minion.id, 'N')).toBeTruthy()
			it 'should return false if minion is not placed', () ->
				placeBase()
				expect(board.moveMinion(team, minion.id, 'N')).toBeFalsy()
			it 'should return false if team is not a team', () ->
				placeBase()
				expect(board.moveMinion(null, 1, 'N')).toBeFalsy()
				expect(board.moveMinion(undefined, 1, 'N')).toBeFalsy()
				expect(board.moveMinion(new Resource(1), 1, 'N')).toBeFalsy()
			it 'should return false if called with wrong team', () ->
				otherTeam = new Team(2)
				placeMinion()
				placeBase()
				expect(board.moveMinion(otherTeam, minion.id, 'N')).toBeFalsy()
			it 'should return false on invalid directions', () ->
				placeMinion()
				placeBase(3, 4)
				expect(board.moveMinion(team, minion.id, 'West')).toBeFalsy()
				expect(board.moveMinion(team, minion.id, 'A')).toBeFalsy()
				expect(board.moveMinion(team, minion.id, 'UP')).toBeFalsy()
				expect(board.moveMinion(team, minion.id, 'NE')).toBeFalsy()
				expect(board.moveMinion(team, minion.id, 'SSW')).toBeFalsy()
				expect(board.moveMinion(team, minion.id, '')).toBeFalsy()
				expect(board.moveMinion(team, minion.id, 0)).toBeFalsy()
				expect(board.moveMinion(team, minion.id, 1)).toBeFalsy()
			it 'should return true on valid directions', () ->
				for direction in ['N','S','E','W','n','s','e','w']
					board = new Board(1, 10)
					minion = new Minion(1, 1, 1, 1, 1, 1, 1)
					minion.turnOver()
					team = new Team(1)
					board.placeBase(team, 2, 2)
					board.placeMinion(team, minion, 1, 1)
					expect(board.moveMinion(team, minion.id, direction)).toBeTruthy()
		describe 'deposit gold', () ->
			it 'should deposit gold into base', () ->
				placeBase(1, 1)
				placeMinion(0, 0)
				minion.carrying = 10
				team.base.gold = 0
				board.moveMinion(team, 1, 'E')
				expect(team.base.gold).toBe(10)
			it 'should reset minion gold on deposit', () ->
				placeBase()
				placeMinion(1, 0)
				minion.carrying = 10
				base.gold = 0
				board.moveMinion(team, 1, 'S')
				expect(minion.carrying).toBe(0)
			it 'should not deposit gold into other teams base', () ->
				placeBase(10, 10)
				board.placeBase(team2, 1, 1)
				placeMinion(0, 0)
				minion.carrying = 10
				team.base.gold = 0
				team2.base.gold = 0
				board.moveMinion(team, 1, 'S')
				expect(minion.carrying).toBe(10)
				expect(team.base.gold).toBe(0)
				expect(team2.base.gold).toBe(0)
			it 'should not deposit gold into base of cornering it', () ->
				placeBase()
				placeMinion(0, 0)
				minion.carrying = 10
				base.gold = 0
				board.moveMinion(team, 1, 'S')
				expect(base.gold).toBe(0)
		describe 'minion has moves available', () ->
			it 'should only be able to move as many times as its speed stat', () ->
				placeMinion(0, 0)
				placeBase()
				for i in [0...minion.speed]
					expect(board.moveMinion(team, minion.id, 'S')).toBeTruthy()
				expect(board.moveMinion(team, minion.id, 'S')).toBeFalsy()
			it 'should be able to move again after its turn is over', () ->
				placeMinion(0, 0)
				placeBase()
				for i in [0...minion.speed]
					expect(board.moveMinion(team, minion.id, 'S')).toBeTruthy()
				minion.turnOver()
				for i in [0...minion.speed]
					expect(board.moveMinion(team, minion.id, 'S')).toBeTruthy()
				expect(board.moveMinion(team, minion.id, 'S')).toBeFalsy()
		describe 'updates data', () ->
			it 'should update the minions coordinates', () ->
				placeMinion(3, 3)
				placeBase(3, 4)
				board.moveMinion(team, minion.id, 'N')
				expect(minion.x).toBe(3)
				expect(minion.y).toBe(2)
		describe 'valid move', () ->
			it 'should return true on valid north move', () ->
				placeMinion()
				placeBase()
				expect(board.moveMinion(team, minion.id, 'N')).toBeTruthy()
			it 'should return true on valid south move', () ->
				placeMinion(1, 3)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'S')).toBeTruthy()
			it 'should return true on valid east move', () ->
				placeMinion(3, 1)
				placeBase(3, 2)
				expect(board.moveMinion(team, minion.id, 'E')).toBeTruthy()
			it 'should return true on valid west move', () ->
				placeMinion()
				placeBase()
				expect(board.moveMinion(team, minion.id, 'W')).toBeTruthy()
			it 'should return false on north move when on north edge', () ->
				placeMinion(1, 0)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'N')).toBeFalsy()
			it 'should return false on south move when on south edge', () ->
				placeMinion(1, board.height - 1)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'S')).toBeFalsy()
			it 'should return false on east move when on east edge', () ->
				placeMinion(board.width - 1, 1)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'E')).toBeFalsy()
			it 'should return false on west move when on west edge', () ->
				placeMinion(0, 1)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'W')).toBeFalsy()
			it 'should return false on moving north into minion', () ->
				board.placeMinion(minion, 1, 2)
				board.placeMinion(minion2, 1, 1)
				placeBase()
				expect(board.moveMinion(team, minion2.id, 'N')).toBeFalsy()
			it 'should return false on moving south into minion', () ->
				board.placeMinion(minion, 1, 0)
				board.placeMinion(minion2, 1, 1)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'S')).toBeFalsy()
			it 'should return false on moving east into minion', () ->
				board.placeMinion(minion, 0, 1)
				board.placeMinion(minion2, 1, 1)
				placeBase()
				expect(board.moveMinion(team, minion.id, 'E')).toBeFalsy()
			it 'should return false on moving west into minion', () ->
				board.placeMinion(minion, 2, 1)
				board.placeMinion(minion2, 1, 1)
				placeBase()
				expect(board.moveMinion(team, minion2.id, 'W')).toBeFalsy()
			it 'should return true on moving west into resource', () ->
				placeBasePasses(5, 5)
				placeMinionPasses(4, 5)
				placeResourcePasses(1, 5)
				minion.turnOver()
				expect(board.moveMinion(team, minion.id, 'W')).toBeTruthy()
				minion.turnOver()
				expect(board.moveMinion(team, minion.id, 'W')).toBeTruthy()
				minion.turnOver()
				expect(board.moveMinion(team, minion.id, 'W')).toBeTruthy()
			it 'should return true on moving into own base', () ->
				placeBasePasses(5, 5)
				placeMinionPasses(4, 5)
				expect(board.moveMinion(team, minion.id, 'E')).toBeTruthy()
			it 'should return false on moving into other base', () ->
				placeBasePasses(5, 5)
				board.placeMinion(team2, minion, 4, 5)
				expect(board.moveMinion(team2, minion.id, 'E')).toBeFalsy()

	describe 'placeBase', () ->
		describe 'placing base', () ->
			it 'should return true with a valid base', () ->
				placeBasePasses()
			it 'should set the teams base', () ->
				placeBase()
				expect(team.base instanceof Base).toBeTruthy()
			it 'should add the base to its list of bases', () ->
				placeBase()
				expect(board.bases.length).toBe(1)
			it 'should add multiple bases to its list of bases', () ->
				placeBase()
				board.placeBase(new Team(2), 6, 6)
				expect(board.bases.length).toBe(2)
				expect(board.bases[0].id).toNotBe(board.bases[1].id)
			it 'should place the base at the coordinates', () ->
				placeBase(3, 4)
				expect(board.getObjectAt(3, 4) instanceof Base).toBeTruthy()
			it 'should map all of the bases occupied cells to the base', () ->
				placeBase(3, 4)
				for x in [3...3+GameRules.base.size]
					for y in [4...4+GameRules.base.size]
						expect(board.getObjectAt(x, y) instanceof Base).toBeTruthy()
			it 'should only map cells occupied by the base', () ->
				placeBase(3, 4)
				objectOnBoardIsNull(2, 4)
				objectOnBoardIsNull(3, 3)
				objectOnBoardIsNull(3+ GameRules.base.size, 4)
				objectOnBoardIsNull(3, 4 + GameRules.base.size)
		describe 'teams can only have one base', () ->
			it 'should not add a second base for a team', () ->
				placeBase(10, 10)
				placeBaseFails(0, 0)
				expect(board.bases.length).toBe(1)
			it 'should add bases for different teams', () ->
				placeBase(3, 4)
				expect(board.placeBase(team2, 1, 1)).toBeTruthy()
				expect(board.bases.length).toBe(2)
		describe 'valid placement', () ->
			it 'should return false with negative coordinates', () ->
				placeBaseFails(-2, 3)
				placeBaseFails(2, -3)
				placeBaseFails(-2, -3)
			it 'should return false with out of range coordinates', () ->
				expect(board.placeBase(team, board.width, 3)).toBeFalsy()
				expect(board.placeBase(team, 2, board.height)).toBeFalsy()
				expect(board.placeBase(team, board.width, board.height)).toBeFalsy()
			it 'should return false when too close to right edge', () ->
				placeBaseFails(board.width + 1 - GameRules.base.size, 3)
			it 'should return true when up against right edge', () ->
				placeBasePasses(board.width - GameRules.base.size, 3)
			it 'should return false when too close to bottom edge', () ->
				placeBaseFails(3, board.height + 1 - GameRules.base.size)
			it 'should return true when up against bottom edge', () ->
				placeBasePasses(3, board.height - GameRules.base.size)
			it 'should fail when placing on a minion', () ->
				board.placeMinion(team, minion, 2, 2)
				placeBaseFails(2, 2)
				reset()
				board.placeMinion(team, minion, 1 + GameRules.base.size, 1 + GameRules.base.size)
				placeBaseFails(2, 2)

	describe 'placeMinion', () ->
		describe 'parameter validation', () ->
			it 'should return false with an undefined minion', () ->
				expect(board.placeMinion(team, undefined)).toBeFalsy()
			it 'should return false with an undefined team', () ->
				expect(board.placeMinion(undefined, minion)).toBeFalsy()
			it 'should return false with a different type', () ->
				expect(board.placeMinion(team, new Resource(1))).toBeFalsy()
				expect(board.placeMinion(new Resource(1), minion)).toBeFalsy()
		describe 'placing minion', () ->
			it 'should return true with a valid minion', () ->
				placeMinionPasses()
			it 'should not add an invalid minion to the teams minions', () ->
				placeMinion(-1, 1)
				expect(team.minions[minion.id]).toBe()
			it 'should add the minion to the teams minions', () ->
				placeMinion()
				teamHasMinion()
			it 'should add multiple minions to the teams minions', () ->
				placeMinions()
				teamHasMinions()
			it 'should add the minion to its list of minions', () ->
				placeMinion()
				teamHasMinion()
			it 'should add multiple minions to its list of minions', () ->
				placeMinions()
				teamHasMinions()
		describe 'valid placement', () ->
			it 'should return false when placing on invalid coordinates', () ->
				placeMinionFails(board.width, 4)
				placeMinionFails(4, board.height)
				placeMinionFails(-1, 4)
				placeMinionFails(4, -1)
			it 'should return true when placing on valid coordinates', () ->
				placeMinionPasses(board.width - 3, 4)
				reset()
				placeMinionPasses(0, 0)
				reset()
				placeMinionPasses(board.width - 1, 4)
				reset()
				placeMinionPasses(4, board.height - 1)
			it 'should return false when placing on the same coordinates', () ->
				placeMinionPasses(3, 4)
				placeMinionFails(3, 4)
			it 'should return true when placing on different coordinates', () ->
				placeMinion()
				expect(board.placeMinion(team, minion2, minion.x, minion.y + 1)).toBeTruthy()
			it 'should return false when placing on a base', () ->
				placeBase(4, 4)
				placeMinionFails(4, 4)

	describe 'placeResource', () ->
		describe 'placing resource', () ->
			it 'should return true with a valid resource', () ->
				placeResourcePasses()
			it 'should add the resource to its list of resources', () ->
				placeResourcePasses()
				expect(board.resources.length).toBe(1)
			it 'should add multiple resources to its list of resources', () ->
				board.placeResource(2, 1)
				board.placeResource(2, 2)
				expect(board.resources.length).toBe(2)
			it 'should create resources with different ids', () ->
				board.placeResource(2, 1)
				board.placeResource(2, 2)
				expect(board.resources[0].id).toNotBe(board.resources[1].id)
			it 'should place the resource at the coordinates', () ->
				placeResource(3, 4)
				expect(board.getObjectAt(3, 4) instanceof Resource).toBeTruthy()
		describe 'valid placement', () ->
			it 'should return false when placing on invalid coordinates', () ->
				placeResourceFails(board.width, 4)
				placeResourceFails(4, board.height)
				placeResourceFails(-1, 4)
				placeResourceFails(4, -1)
			it 'should return true when placing on valid coordinates', () ->
				placeResourcePasses(7, 4)
				reset()
				placeResourcePasses(0, 0)
				reset()
				placeResourcePasses(board.width - 1, 4)
				reset()
				placeResourcePasses(4, board.height - 1)
				reset()
			it 'should return false when placing on the same coordinates', () ->
				board.placeResource(7, 4)
				expect(board.placeResource(7, 4)).toBeFalsy()
			it 'should return true when placing on different coordinates', () ->
				board.placeResource(7, 4)
				expect(board.placeResource(7, 5)).toBeTruthy()
			it 'should return false when placing on a base', () ->
				placeBase(7, 4)
				placeResourceFails(7, 4)