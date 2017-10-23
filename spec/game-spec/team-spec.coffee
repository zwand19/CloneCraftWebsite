Base = require '../../server/entities/base'
GameRules = require '../../server/settings/gameRules'
Minion = require '../../server/entities/minion'
Team = require '../../server/entities/team'

describe 'Team', () ->
	team = {}
	minion = {}
	minion2 = {}

	beforeEach () -> 
		team = new Team(1)
		minion = new Minion(1, 1, 1, 1, 1, 1, 1)
		minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)

	describe 'Constructor', () ->
		it 'should set default stats', () ->
			expect(team.stats.minionsKilled).toBe(0)
			expect(team.stats.greaterMinionsBuilt).toBe(0)
			expect(team.stats.lesserMinionsBuilt).toBe(0)
			expect(team.stats.tanksBuilt).toBe(0)
			expect(team.stats.archersBuilt).toBe(0)
			expect(team.stats.seersBuilt).toBe(0)
			expect(team.stats.gruntsBuilt).toBe(0)
			expect(team.stats.minersBuilt).toBe(0)
			expect(team.stats.foxesBuilt).toBe(0)
			expect(team.goldMined).toBe(0)

	describe 'add/get/killed minion', () ->
		it 'should map minion ids to minion', () ->
			team.addMinion(minion)
			expect(team.getMinion(minion.id)).toBe(minion)
		it 'should set its team to the team its added to', () ->
			minion = new Minion(1, 1, 1, {}, 1, 1, 1, 1, 1)
			team.addMinion(minion)
			expect(minion.team).toBe(team)
		it 'should return undefined when no minions added', () ->
			expect(team.getMinion(1)).toBe(undefined)
		it 'should return undefined passing wrong id', () ->
			minion = new Minion(1, 1, 1, 1, 1, 1, 1, 1)
			team.addMinion(minion)
			expect(team.getMinion(155)).toBe(undefined)
		it 'should overwrite old minons if same id', () ->
			minion2 = new Minion(1, 1, 2, 1, 1, 1, 1, 1)
			team.addMinion(minion)
			expect(team.getMinion(1)).toBe(minion)
			team.addMinion(minion2)
			expect(team.getMinion(1)).toBe(minion2)
		it 'should store multiple minions', () ->
			team.addMinion(minion)
			expect(team.getMinion(minion.id)).toBe(minion)
			team.addMinion(minion2)
			expect(team.getMinion(minion2.id)).toBe(minion2)
		it 'should delete a killed minion from its list of minions', () ->
			team.addMinion(minion)
			team.minionKilled(minion.id)
			expect(team.getMinion(minion.id)).toBe()
		it 'should delete killed minions from its list of minions', () ->
			team.addMinion(minion)
			team.addMinion(minion2)
			team.minionKilled(minion.id)
			expect(team.getMinion(minion.id)).toBe()
			expect(team.getMinion(minion2.id)).toBe(minion2)
			team.minionKilled(minion2.id)
			expect(team.getMinion(minion2.id)).toBe()
		it 'should store stats for foxes', () ->
			minion.s = 2
			team.addMinion(minion)
			expect(team.stats.foxesBuilt).toBe(1)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(0)
			minion2.s = 10
			team.addMinion(minion2)
			expect(team.stats.foxesBuilt).toBe(2)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(1)
		it 'should store stats for tanks', () ->
			minion.h = 2
			team.addMinion(minion)
			expect(team.stats.foxesBuilt).toBe(0)
			expect(team.stats.tanksBuilt).toBe(1)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(0)
			minion2.h = 10
			team.addMinion(minion2)
			expect(team.stats.tanksBuilt).toBe(2)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(1)
		it 'should store stats for archers', () ->
			minion.d = 2
			team.addMinion(minion)
			expect(team.stats.archersBuilt).toBe(1)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(0)
			minion2.r = 10
			team.addMinion(minion2)
			expect(team.stats.archersBuilt).toBe(2)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(1)
		it 'should store stats for seers', () ->
			minion.v = 10
			team.addMinion(minion)
			expect(team.stats.seersBuilt).toBe(1)
			expect(team.stats.lesserMinionsBuilt).toBe(0)
			expect(team.stats.greaterMinionsBuilt).toBe(1)
			minion2.v = 2
			team.addMinion(minion2)
			expect(team.stats.seersBuilt).toBe(2)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(1)
		it 'should store stats for miners', () ->
			minion.m = 2
			team.addMinion(minion)
			expect(team.stats.minersBuilt).toBe(1)
			expect(team.stats.lesserMinionsBuilt).toBe(1)
			expect(team.stats.greaterMinionsBuilt).toBe(0)
			minion2.m = 2
			team.addMinion(minion2)
			expect(team.stats.minersBuilt).toBe(2)
			expect(team.stats.gruntsBuilt).toBe(0)
			expect(team.stats.lesserMinionsBuilt).toBe(2)
			expect(team.stats.greaterMinionsBuilt).toBe(0)
		it 'should store stats for grunts', () ->
			minion.s = 3
			minion.d = 1
			minion.r = 2
			minion.h = 3
			minion.v = 3
			minion.m = 3
			team.addMinion(minion)
			expect(team.stats.gruntsBuilt).toBe(1)
			expect(team.stats.lesserMinionsBuilt).toBe(0)
			expect(team.stats.greaterMinionsBuilt).toBe(1)
			minion2.s = 3
			minion2.d = 2
			minion2.r = 1
			minion2.h = 3
			minion2.v = 3
			minion2.m = 3
			team.addMinion(minion2)
			expect(team.stats.gruntsBuilt).toBe(2)
			expect(team.stats.lesserMinionsBuilt).toBe(0)
			expect(team.stats.greaterMinionsBuilt).toBe(2)

	describe 'baseKilled', () ->
		it 'should reset the base to null', () ->
			team.base = {}
			team.baseKilled({})
			expect(team.base).toBeNull()
		#it 'should convert all minions to the other team', () ->
		#	team2 = new Team(2)
		#	team.base = {}
		#	team.addMinion(minion)
		#	team.addMinion(minion2)
		#	team.baseKilled(team2)
		#	expect(minion.team).toBe(team2)
		#	expect(minion2.team).toBe(team2)
		#it 'should reset minions after base killed', () ->
		#	team2 = new Team(2)
		#	team.base = {}
		#	team.addMinion(minion)
		#	team.addMinion(minion2)
		#	team.baseKilled(team2)
		#	expect(team.minions[minion.id]).toBe()
		#	expect(team.minions[minion2.id]).toBe()

	describe 'hasMaxMinions', () ->
		it 'should return false if team has no minions', () ->
			expect(team.hasMaxMinions()).toBeFalsy()
		it 'should return false if team has less than max minions', () ->
			for i in [1...GameRules.teamMaxMinions]
				team.addMinion(new Minion(i, 1, 1, 1, 1, 1, 1))
			expect(team.hasMaxMinions()).toBeFalsy()
		it 'should return true if team has max minions', () ->
			for i in [0...GameRules.teamMaxMinions]
				team.addMinion(new Minion(i, 1, 1, 1, 1, 1, 1))
			expect(team.hasMaxMinions()).toBeTruthy()

	describe 'turnOver', () ->
		it 'should reset base canBuild', () ->
			base = new Base(1, 1, 1)
			team.base = base
			base.canBuild = false
			team.turnOver()
			expect(base.canBuild).toBeTruthy()
		it 'should reset minions canAct', () ->
			base = new Base(1, 1, 1)
			team.base = base
			team.addMinion(minion)
			team.addMinion(minion2)
			minion.canAct = false
			team.turnOver()
			expect(minion.canAct).toBeTruthy()
			expect(minion2.canAct).toBeTruthy()