Base = require '../../server/entities/base'
GameRules = require '../../server/settings/gameRules'
Minion = require '../../server/entities/minion'
Resource = require '../../server/entities/resource'
Team = require '../../server/entities/team'
TestHelpers = require '../testHelpers'

describe 'Minion', () ->
	minion = {}
	minion2 = {}
	resource = {}
	team = {}

	beforeEach () -> 
		minion = new Minion(1, 1, 1, 1, 1, 1, 1)
		minion2 = new Minion(2, 1, 1, 1, 1, 1, 1)
		resource = new Resource(1, 1, 2)
		resource.placed(1, 2)
		setPosOfMinion(minion, 1, 1)
		setPosOfMinion(minion2, 2, 1)
		team = new Team(1)
		minion.team = team
		minion2.team = team
		minion.turnOver()
		minion2.turnOver()
		
	handOffFails = () ->
		expect(minion.handOffGold(minion2)).toBeFalsy()
	handOffPasses = () ->
		expect(minion.handOffGold(minion2)).toBeTruthy()
	mineFails = () ->
		expect(minion.mine(resource)).toBeFalsy()
	minePasses = () ->
		expect(minion.mine(resource)).toBeTruthy()
	setPosOfMinion = (m, x, y) ->
		m.x = x
		m.y = y

	describe 'Constructor', () ->
		it 'should have a constructor', () ->
			expect(minion).toBeDefined()
		it 'should be valid on valid parameters', () ->
			expect(minion).not.toBeNull()
		it 'should initialize carrying to 0', () ->
			expect(minion.carrying).toBe(0)
		describe 'Speed', () ->
			it 'should throw error if less than 0', () ->
				failed = false
				try
					minion = new Minion(1, 0, 1, 1, 1, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should throw error if greater than 10', () ->
				failed = false
				try
					minion = new Minion(1, 11, 1, 1, 1, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should ignore a speed stat of 1', () ->
				expect(minion.speed).toBe(GameRules.minion.speed.base)
			it 'should increase speed with a stat of 2', () ->
				expect(new Minion(1, 2, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 1)
			it 'should increase speed every 2 stat points', () ->
				expect(new Minion(1, 4, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 2)
				expect(new Minion(1, 6, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 3)
				expect(new Minion(1, 8, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 4)
				expect(new Minion(1, 10, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 5)
			it 'should ignore the odd speed stat points', () ->
				expect(new Minion(1, 3, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 1)
				expect(new Minion(1, 5, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 2)
				expect(new Minion(1, 7, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 3)
				expect(new Minion(1, 9, 1, 1, 1, 1, 1).speed).toBe(GameRules.minion.speed.base + 4)
		describe 'Damage', () ->
			it 'should throw error if less than 0', () ->
				failed = false
				try
					minion = new Minion(1, 1, 0, 1, 1, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should throw error if greater than max', () ->
				failed = false
				try
					minion = new Minion(1, 1, GameRules.minion.damage.max + 1, 1, 1, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should gain damage per stat point', () ->
				for i in [1...GameRules.minion.damage.max]
					expect(new Minion(1, 1, i, 1, 1, 1, 1).damage).toBe(GameRules.minion.damage.base + GameRules.minion.damage.per * i)
		describe 'Health', () ->
			it 'should throw error if less than 0', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 0, 1, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should not error if greater than 10', () ->
				minion = new Minion(1, 1, 1, 11, 1, 1, 1)
				TestHelpers.pass()
			it 'should gain health per stat point', () ->
				for i in [1...10]
					expect(new Minion(1, 1, 1, i, 1, 1, 1).health).toBe(GameRules.minion.health.base + GameRules.minion.health.per * i)
		describe 'Vision', () ->
			it 'should throw error if less than 0', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 1, 0, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should throw error if greater than max', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 1, GameRules.mining.max + 1, 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should gain vision per stat point', () ->
				for i in [1...GameRules.minion.vision.max]
					expect(new Minion(1, 1, 1, 1, i, 1, 1).vision).toBe(GameRules.minion.vision.base + i)
		describe 'Mining', () ->
			it 'should throw error if less than 0', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 1, 1, 0, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should throw error if greater than max', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 1, 1, GameRules.minion.mining.max + 1, 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should gain mining per stat point', () ->
				for i in [1...GameRules.minion.mining.max]
					expect(new Minion(1, 1, 1, 1, 1, i, 1).mining).toBe(GameRules.minion.mining.base + GameRules.minion.mining.per * i)
		describe 'Range', () ->
			it 'should throw error if less than 0', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 1, 1, 1, 0)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should throw error if greater than max', () ->
				failed = false
				try
					minion = new Minion(1, 1, 1, 1, 1, 1, GameRules.minion.range.max + 1)
				catch
					failed = true
				finally 
					expect(failed).toBeTruthy()
			it 'should gain range per stat point', () ->
				for i in [1...GameRules.minion.range.max]
					expect(new Minion(1, 1, 1, 1, 1, 1, i).range).toBe(GameRules.minion.range.base + GameRules.minion.range.per * i)

	describe 'applyDamage', () ->
		it 'should subtract health', () ->
			startingHealth = minion.health
			minion.applyDamage(10)
			expect(minion.health).toBe(startingHealth - 10)
		it 'should not subtract any health on apply 0 damage', () ->
			startingHealth = minion.health
			minion.applyDamage(0)
			expect(minion.health).toBe(startingHealth)
		it 'should not subtract any health on apply negative damage', () ->
			startingHealth = minion.health
			minion.applyDamage(-5)
			expect(minion.health).toBe(startingHealth)
		it 'should return false if doesnt kill minion', () ->
			startingHealth = minion.health
			results = minion.applyDamage(5)
			expect(results).toBeFalsy()
		it 'should return true if kills minion', () ->
			startingHealth = minion.health
			results = minion.applyDamage(5000)
			expect(results).toBeTruthy()
		it 'should return true if exactly kills minion', () ->
			startingHealth = minion.health
			results = minion.applyDamage(startingHealth)
			expect(results).toBeTruthy()
		it 'should return false if leaves 1 health', () ->
			startingHealth = minion.health
			results = minion.applyDamage(startingHealth - 1)
			expect(results).toBeFalsy()

	describe 'attack', () ->
		it 'should return false if trying to attack a resource', () ->
			setPosOfMinion(minion, 15, 15)
			resource = new Resource(1, 15, 14)
			expect(minion.attack(resource)).toBeFalsy()
		it 'should return false on null or undefined argument', () ->
			setPosOfMinion(minion, 15, 15)
			expect(minion.attack(null)).toBeFalsy()
			expect(minion.attack()).toBeFalsy()
		it 'should return false if cant attack', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 15, 16)
			minion.canAct = false
			expect(minion.attack(minion2)).toBeFalsy()
		it 'should return false if target is dead', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 15, 16)
			minion2.health = 0
			expect(minion.attack(minion2)).toBeFalsy()
		it 'should return false if attacking self', () ->
			setPosOfMinion(minion, 15, 15)
			expect(minion.attack(minion)).toBeFalsy()
		it 'should be able to attack a base', () ->
			base = new Base(1, 1, 2)
			base.team = new Team(2)
			expect(minion.attack(base)).toBeTruthy()
		it 'should not be able to attack your own a base', () ->
			base = new Base(1, 1, 2)
			base.team = team
			expect(minion.attack(base)).toBeFalsy()
		it 'should return false on second attack of turn', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 15, 16)
			minion2.health = 1000
			minion.attack(minion2)
			expect(minion.attack(minion2)).toBeFalsy()
		it 'should be able to attack again next turn', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 15, 16)
			minion2.health = 1000
			minion.attack(minion2)
			minion.turnOver()
			expect(minion.attack(minion2)).toBeTruthy()
		it 'should not be able to attack minions out of range', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 14-minion.range, 15) 
			minion3 = new Minion(2, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion3, 15, 14-minion.range)
			minion4 = new Minion(2, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion4, 16, 15-minion.range)
			minion5 = new Minion(2, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion5, 14+minion.range, 13) 
			expect(minion.attack(minion2)).toBeFalsy()
			expect(minion.attack(minion3)).toBeFalsy()
			expect(minion.attack(minion4)).toBeFalsy()
			expect(minion.attack(minion5)).toBeFalsy()
		it 'should be able to attack minions in range', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 15-minion.range, 15) 
			minion3 = new Minion(2, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion3, 15, 15-minion.range)
			minion4 = new Minion(2, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion4, 15, 15-minion.range)
			minion5 = new Minion(2, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion5, 13+minion.range, 13) 
			expect(minion.attack(minion2)).toBeTruthy()
			minion.canAct = true
			expect(minion.attack(minion3)).toBeTruthy()
			minion.canAct = true
			expect(minion.attack(minion4)).toBeTruthy()
			minion.canAct = true
			expect(minion.attack(minion5)).toBeTruthy()
		it 'should reduce targets health on attack', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 14, 15) 
			health = minion2.health
			minion.attack(minion2)
			expect(minion2.health).toBe(health - minion.damage)
		it 'should kill minions with low enough health', () ->
			setPosOfMinion(minion, 15, 15)
			setPosOfMinion(minion2, 14, 15)
			minion2.health = minion.damage
			minion.attack(minion2)
			expect(minion2.isAlive()).toBeFalsy()

	describe 'canAttackCell', () ->
		it 'should use attack range', () ->
			minion = new Minion(1, 1, 5, 1, 1, 1, 5)
			setPosOfMinion(minion, 15, 15)
			expect(minion.canAttackCell(15 + minion.range, 15)).toBeTruthy()
			expect(minion.canSeeCell(15 + minion.range, 15)).toBeFalsy()
		
	describe 'canSeeCell', () ->
		it 'should use vision', () ->
			minion = new Minion(1, 1, 1, 1, 8, 1, 1)
			setPosOfMinion(minion, 15, 15)
			expect(minion.canAttackCell(15 + minion.vision, 15)).toBeFalsy()
			expect(minion.canSeeCell(15 + minion.vision, 15)).toBeTruthy()

	describe 'cellIsInRange', () ->
		it 'should return true for own cell', () ->
			setPosOfMinion(minion, 5, 5)
			expect(minion.cellIsInRange(5, 5, 2)).toBeTruthy()
		it 'should return true for cell neighboring minion', () ->
			setPosOfMinion(minion, 5, 5)
			expect(minion.cellIsInRange(5, 6, 2)).toBeTruthy()
			expect(minion.cellIsInRange(5, 4, 2)).toBeTruthy()
			expect(minion.cellIsInRange(6, 5, 2)).toBeTruthy()
			expect(minion.cellIsInRange(4, 5, 2)).toBeTruthy()
		it 'should return true for cell at edge of vision in cardinal directions', () ->
			setPosOfMinion(minion, 5, 5)
			expect(minion.cellIsInRange(3, 5, 2)).toBeTruthy()
			expect(minion.cellIsInRange(7, 5, 2)).toBeTruthy()
			expect(minion.cellIsInRange(5, 3, 2)).toBeTruthy()
			expect(minion.cellIsInRange(5, 7, 2)).toBeTruthy()
		it 'should return false for cell just past edge of vision in cardinal directions', () ->
			setPosOfMinion(minion, 5, 5)
			expect(minion.cellIsInRange(2, 5, 2)).toBeFalsy()
			expect(minion.cellIsInRange(8, 5, 2)).toBeFalsy()
			expect(minion.cellIsInRange(5, 2, 2)).toBeFalsy()
			expect(minion.cellIsInRange(5, 8, 2)).toBeFalsy()
		it 'should return true for cells along diagonal border', () ->
			setPosOfMinion(minion, 5, 5)
			expect(minion.cellIsInRange(3, 4, 3)).toBeTruthy()
			expect(minion.cellIsInRange(7, 4, 3)).toBeTruthy()
			expect(minion.cellIsInRange(6, 3, 3)).toBeTruthy()
			expect(minion.cellIsInRange(6, 7, 3)).toBeTruthy()
		it 'should return false for cells outisde diagonal border', () ->
			setPosOfMinion(minion, 5, 5)
			expect(minion.cellIsInRange(3, 3, 3)).toBeFalsy()
			expect(minion.cellIsInRange(8, 4, 3)).toBeFalsy()
			expect(minion.cellIsInRange(7, 3, 3)).toBeFalsy()
			expect(minion.cellIsInRange(3, 7, 3)).toBeFalsy()

	describe 'handOffGold', () ->
		it 'should return true on valid hand off', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 1)
			handOffPasses()
		it 'should set the gold to 0', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 1)
			minion.handOffGold(minion2)
			expect(minion.carrying).toBe(0)
		it 'should return false if minion not carrying anything', () ->
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 1)
			handOffFails()
		it 'should return false if minion not a minion', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			minion2 = null
			handOffFails()
		it 'should fail if minions are cornering each other', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 2)
			handOffFails()
		it 'should fail if minions are on different teams', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 1)
			minion2.team = new Team(2)
			handOffFails()
		it 'should fail if minions are two cells away', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 3, 1)
			handOffFails()
		it 'should fail if minion is passing to same coordinates', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 1, 1)
			handOffFails()
		it 'should pass resources to other minion', () ->
			minion.carrying = 10
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 1)
			minion.handOffGold(minion2)
			expect(minion2.carrying).toBe(10)
		it 'should not hand off resources if other minion is already carrying some', () ->
			minion.carrying = 10
			minion2.carrying = 15
			setPosOfMinion(minion, 1, 1)
			setPosOfMinion(minion2, 2, 1)
			minion.handOffGold(minion2)
			expect(minion.carrying).toBe(10)
			expect(minion2.carrying).toBe(15)

	describe 'isAlive', () ->
		it 'should return false if health is negative', () ->
			minion.health = -5
			expect(minion.isAlive()).toBeFalsy()
		it 'should return false if health is 0', () ->
			minion.health = 0
			expect(minion.isAlive()).toBeFalsy()
		it 'should return true if health is positive', () ->
			minion.health = 1
			expect(minion.isAlive()).toBeTruthy()

	describe 'mine', () ->
		it 'should pass on valid mine', () ->
			minePasses()
		it 'should fail if resource is not a resource', () ->
			resource = minion2
			mineFails()
			resource = null
			mineFails()
			resource = undefined
			mineFails()
		it 'should fail if the resource is cornering the minion', () ->
			resource.x = 2
			resource.y = 2
			mineFails()
		it 'should fail if the resource is two cells away', () ->
			resource.x = 3
			resource.y = 1
			mineFails()
			resource.x = 1
			resource.y = 3
			mineFails()
		it 'should add gold on mine', () ->
			minion.mine(resource)
			expect(minion.carrying).toBe(minion.mining)
		it 'should not be able to mine twice', () ->
			minePasses()
			resource.placed resource.x, resource.y
			minion.carrying = 0
			mineFails()
		it 'should not mine if already carrying', () ->
			minion = minion
			minion.receiveResources(30)
			minion.mine(resource)
			expect(minion.carrying).toBe(30)

	describe 'moved', () ->
		it 'should return false if has no moves remaining', () ->
			setPosOfMinion(minion, 0, 0)
			minion.movesRemaining = 0
			expect(minion.moved({x: 1, y: 0})).toBeFalsy()
		it 'should return true while moves remain', () ->
			setPosOfMinion(minion, 0, 0)
			for i in [0...minion.speed]
				expect(minion.moved({x: i + 1, y: 0})).toBeTruthy()
		it 'should return false if trying to move more than one cell', () ->
			setPosOfMinion(minion, 2, 2)
			expect(minion.moved({x: 2, y: 0})).toBeFalsy()
			expect(minion.moved({x: 0, y: 2})).toBeFalsy()
			expect(minion.moved({x: 3, y: 3})).toBeFalsy()
		it 'should not decrement moves remaining on an invalid move', () ->
			setPosOfMinion(minion, 2, 2)
			for i in [0...minion.speed]
				minion.moved({x: 2, y: 0})
			expect(minion.moved({x: 2, y: 1})).toBeTruthy()
		it 'should not change coordinates on an invalid move', () ->
			setPosOfMinion(minion, 2, 2)
			minion.moved({x: 2, y: 0})
			expect(minion.y).toBe(2)
		it 'should change y on a north move', () ->
			setPosOfMinion(minion, 2, 2)
			minion.moved({x: 2, y: 1})
			expect(minion.y).toBe(1)
		it 'should change x on a east move', () ->
			setPosOfMinion(minion, 2, 2)
			minion.moved({x: 3, y: 2})
			expect(minion.x).toBe(3)

	describe 'receiveResources', () ->
		it 'should add resources', () ->
			minion.receiveResources(20)
			expect(minion.carrying).toBe(20)
		it 'should not add resources together on two calls', () ->
			minion.receiveResources(20)
			minion.receiveResources(30)
			expect(minion.carrying).toBe(20)
		it 'should not add resources to resources mined', () ->
			minion.mine(resource)
			minion.receiveResources(30)
			expect(minion.carrying).toBe(minion.mining)

	describe 'resetCarrying', () ->
		it 'should reset carrying to 0', () ->
			minion.receiveResources(20)
			expect(minion.carrying).toNotBe(0)
			minion.resetCarrying()
			expect(minion.carrying).toBe(0)

	describe 'turnOver', () ->
		it 'should reset moves remaining', () ->
			minion.movesRemaining = 0
			minion.turnOver()
			expect(minion.movesRemaining).toBe(minion.speed)
			minion.movesRemaining = 1
			minion.turnOver()
			expect(minion.movesRemaining).toBe(minion.speed)
		it 'should reset can act', () ->
			minion.canAct = false
			minion.turnOver()
			expect(minion.canAct).toBeTruthy()