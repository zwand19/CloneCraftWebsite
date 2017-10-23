Base = require '../../server/entities/base'
GameRules = require '../../server/settings/gameRules'
Minion = require '../../server/entities/minion'

describe 'Base', () ->
	base = {}
	startingHealth = 0
	startingGold = 0
	baseSize = GameRules.base.size
	
	beforeEach () -> 
		GameRules.base.size = baseSize
		base = new Base(1, 2, 2)
		startingHealth = base.health
		startingGold = base.gold
		
	applyDamageKills = (damage) ->
		expect(base.applyDamage(damage)).toBeTruthy()
	applyDamageDoesntKill = (damage) ->
		expect(base.applyDamage(damage)).toBeFalsy()
	baseIsAlive = () ->
		expect(base.isAlive()).toBeTruthy()
	baseIsDead = () ->
		expect(base.isAlive()).toBeFalsy()
	baseOccupiesCell = (x, y) ->
		expect(base.occupiesCell(x, y)).toBeTruthy()
	baseDoesntOccupiesCell = (x, y) ->
		expect(base.occupiesCell(x, y)).toBeFalsy()
	checkDistanceFromBase = (x, y, expected) ->
		expect(base.distanceFromBase(x, y)).toBe(expected)
	checkGold = (gold) ->
		expect(base.gold).toBe(gold)
	checkHealth = (health) ->
		expect(base.health).toBe(health)
	ensureGold = () ->
		base.goldDeposited(200)
		startingGold = base.gold
	setBaseSize = (size) ->
		GameRules.base.size = size
		base = new Base(1, 2, 2)
	
	describe 'Constructor', () ->
		it 'should initialize health', () ->
			expect(new Base(1, 1, 1, 1).health).toBe(GameRules.base.startingHealth)
		it 'should initialize gold', () ->
			expect(new Base(1, 1, 1, 1).gold).toBe(GameRules.base.startingGold)

	describe 'applyDamage', () ->
		it 'should subtract health', () ->
			base.applyDamage(10)
			checkHealth(startingHealth - 10)
		it 'should not subtract any health on apply 0 damage', () ->
			base.applyDamage(0)
			checkHealth(startingHealth)
		it 'should not subtract any health on apply negative damage', () ->
			base.applyDamage(-5)
			checkHealth(startingHealth)
		it 'should return false if doesnt kill base', () ->
			applyDamageDoesntKill(startingHealth - 1)
		it 'should return true if kills base', () ->
			applyDamageKills(startingHealth + 1)
		it 'should return true if exactly kills base', () ->
			applyDamageKills(startingHealth)

	describe 'distanceFromBase', () ->
		it 'should return 0 for the cell the base is on', () ->
			checkDistanceFromBase(base.x, base.y, 0)
		it 'should return 1 for the cells immediately west and north of the base', () ->
			checkDistanceFromBase(base.x - 1, base.y, 1)
			checkDistanceFromBase(base.x, base.y - 1, 1)
		it 'should return 0 for cells in the base', () ->
			setBaseSize(5)
			checkDistanceFromBase(base.x + 1, base.y + 1, 0)
			checkDistanceFromBase(base.x + 4, base.y + 1, 0)
			checkDistanceFromBase(base.x + 1, base.y + 4, 0)
			checkDistanceFromBase(base.x + 4, base.y + 4, 0)
		it 'should return 1 for cells immediately east and south of the base', () ->
			setBaseSize(5)
			checkDistanceFromBase(base.x, base.y + 5, 1)
			checkDistanceFromBase(base.x + 5, base.y, 1)
			checkDistanceFromBase(base.x + 5, base.y + 4, 1)
			checkDistanceFromBase(base.x + 4, base.y + 5, 1)
		it 'should return 2 for cells cornering the base', () ->
			setBaseSize(3)
			checkDistanceFromBase(base.x - 1, base.y - 1, 2)
			checkDistanceFromBase(base.x - 1, base.y + 3, 2)
			checkDistanceFromBase(base.x + 3, base.y - 1, 2)
			checkDistanceFromBase(base.x + 3, base.y + 3, 2)
		it 'should return 2 for cells two cells away from sides', () ->
			setBaseSize(4)
			checkDistanceFromBase(base.x - 2, base.y + 3, 2)
			checkDistanceFromBase(base.x + 5, base.y, 2)
			checkDistanceFromBase(base.x + 1, base.y - 2, 2)
			checkDistanceFromBase(base.x + 3, base.y + 5, 2)
		it 'should return 3 for cells a knights move away from corner', () ->
			setBaseSize(4)
			checkDistanceFromBase(base.x - 2, base.y - 1, 3)
			checkDistanceFromBase(base.x - 1, base.y + 5, 3)
			checkDistanceFromBase(base.x + 5, base.y - 1, 3)
			checkDistanceFromBase(base.x + 4, base.y + 5, 3)
		it 'should return 4 for cells two diagonals away from corner', () ->
			setBaseSize(4)
			checkDistanceFromBase(base.x - 2, base.y - 2, 4)
			checkDistanceFromBase(base.x - 2, base.y + 5, 4)
			checkDistanceFromBase(base.x + 5, base.y - 2, 4)
			checkDistanceFromBase(base.x + 5, base.y + 5, 4)
		it 'should return correctly for a base of size 1', () ->
			setBaseSize(1)
			checkDistanceFromBase(base.x - 2, base.y - 2, 4)
			checkDistanceFromBase(base.x - 2, base.y + 5, 7)
			checkDistanceFromBase(base.x + 5, base.y - 2, 7)
			checkDistanceFromBase(base.x + 5, base.y + 5, 10)

	describe 'getCellsOccupied', () ->
		beforeEach () -> 
			base = new Base(1, 2, 3)
		it 'should return a list of cells', () ->
			expect(base.getCellsOccupied().length).toBeGreaterThan(0)
			expect(base.getCellsOccupied()[0].x).toBeDefined()
			expect(base.getCellsOccupied()[0].y).toBeDefined()
		it 'should return the correct amount of cells', () ->
			expect(base.getCellsOccupied().length).toBe(GameRules.base.size * GameRules.base.size)
		it 'should return the correct coordinates', () ->
			expect(base.getCellsOccupied()[0].x).toBe(2)
			expect(base.getCellsOccupied()[0].y).toBe(3)
			expect(base.getCellsOccupied()[GameRules.base.size - 1].x).toBe(2 + GameRules.base.size - 1)
			expect(base.getCellsOccupied()[GameRules.base.size - 1].y).toBe(3)
			expect(base.getCellsOccupied()[GameRules.base.size * GameRules.base.size - 1].x).toBe(2 + GameRules.base.size - 1)
			expect(base.getCellsOccupied()[GameRules.base.size * GameRules.base.size - 1].y).toBe(3 + GameRules.base.size - 1)

	describe 'goldDeposited', () ->
		it 'should do nothing on 0 deposited', () ->
			base.goldDeposited(0)
			checkGold(startingGold)
		it 'should increase gold', () ->
			base.goldDeposited(1)
			checkGold(startingGold + 1)
		it 'should increase gold twice ', () ->
			base.goldDeposited(1)
			base.goldDeposited(1)
			checkGold(startingGold + 2)
		it 'should increase gold by amount deposited', () ->
			base.goldDeposited(127)
			checkGold(startingGold + 127)
		it 'should do nothing on negative amounts deposited', () ->
			base.goldDeposited(-1)
			checkGold(startingGold)
			base.goldDeposited(-35)
			checkGold(startingGold)

	describe 'isAlive', () ->
		it 'should return false if health is negative', () ->
			base.health = -5
			baseIsDead()
		it 'should return false if health is 0', () ->
			base.health = 0
			baseIsDead()
		it 'should return true if health is positive', () ->
			base.health = 1
			baseIsAlive()

	describe 'makePurchase', () ->
		it 'should return false when too expensive', () ->
			ensureGold()
			expect(base.makePurchase(base.gold + 1)).toBeFalsy()
		it 'should not change gold when too expensive', () ->
			ensureGold()
			base.makePurchase(base.gold + 1)
			checkGold(startingGold)
		it 'should return true when affordable', () ->
			ensureGold()
			expect(base.makePurchase(base.gold)).toBeTruthy()
		it 'should subtract gold when affordable', () ->
			ensureGold()
			base.makePurchase(80)
			checkGold(startingGold - 80)
		it 'should be able to use all of gold', () ->
			ensureGold()
			base.makePurchase(base.gold)
			checkGold(0)
		it 'should return false when cost is negative', () ->
			ensureGold()
			expect(base.makePurchase(-5)).toBeFalsy()
		it 'should not change gold when cost is negative', () ->
			ensureGold()
			base.makePurchase(-5)
			checkGold(startingGold)

	describe 'occupiesCell', () ->
		beforeEach () -> 
			base = new Base(1, 2, 2)
		it 'should return true for the cell the base is on', () ->
			baseOccupiesCell(2, 2)
		it 'should return false for cells west of the base', () ->
			baseDoesntOccupiesCell(2, 1)
			baseDoesntOccupiesCell(1, 1)
			baseDoesntOccupiesCell(0, 3)
		it 'should return false for cells north of the base', () ->
			baseDoesntOccupiesCell(2, 1)
			baseDoesntOccupiesCell(2, 0)
			baseDoesntOccupiesCell(3, 1)
		it 'should return true for cells in the base', () ->
			baseOccupiesCell(2, 1 + GameRules.base.size)
			baseOccupiesCell(1 + GameRules.base.size, 1 + GameRules.base.size)
			baseOccupiesCell(1 + GameRules.base.size, 2)
		it 'should return false for cells just outside the base', () ->
			baseDoesntOccupiesCell(2, 2 + GameRules.base.size)
			baseDoesntOccupiesCell(2 + GameRules.base.size, 1 + GameRules.base.size)
			baseDoesntOccupiesCell(1 + GameRules.base.size, 2 + GameRules.base.size)
			baseDoesntOccupiesCell(2 + GameRules.base.size, 2)

	describe 'purchaseLesserMinion', () ->
		describe 'validation', () ->
			it 'should return null on undefined stats', () ->
				expect(base.purchaseLesserMinion(1)).toBeNull()
			it 'should return a minion on valid stats', () ->
				ensureGold()
				minion = base.purchaseLesserMinion(1, {d: GameRules.building.lesserMinionStats - 5, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(minion instanceof Minion).toBeTruthy()
			it 'should return null if canBuild is false', () ->
				ensureGold()
				base.canBuild = false
				expect(base.purchaseLesserMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})).toBeFalsy()
			it 'should return null with too many stat points', () ->
				ensureGold()
				minion = base.purchaseLesserMinion(1, {d: GameRules.building.lesserMinionStats - 3, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(minion).toBeNull()
			it 'should return null if a stat is 0', () ->
				ensureGold()
				minion = base.purchaseLesserMinion(1, {d: 1, s: 2, h: 1, v: 0, m: 1, r: 1})
				expect(minion).toBeNull()
		describe 'gold validation', () ->
			it 'should return null if dont have the gold', () ->
				base.gold = 0
				minion = base.purchaseLesserMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(minion).toBeNull()
			it 'should not alter the gold if didnt buy', () ->
				minion = base.purchaseLesserMinion(1, {d: 0, s: 1, h: 1, v: 1, m: 1, r: 1})
				checkGold(startingGold)
			it 'should alter the gold if bought', () ->
				ensureGold()
				gold = base.gold
				minion = base.purchaseLesserMinion(1, {d: 2, s: 1, h: 1, v: 1, m: 1, r: 1})
				checkGold(gold - GameRules.building.costOfLesserMinion)
		describe 'created minion', () ->
			it 'should set the damage stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseLesserMinion(1, {d: 3, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(boughtMinion.damage).toBeGreaterThan(minion.damage)
			it 'should set the speed stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseLesserMinion(1, {d: 1, s: 3, h: 1, v: 1, m: 1, r: 1})
				expect(boughtMinion.speed).toBeGreaterThan(minion.speed)
			it 'should set the health stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseLesserMinion(1, {d: 1, s: 1, h: 3, v: 1, m: 1, r: 1})
				expect(boughtMinion.health).toBeGreaterThan(minion.health)
			it 'should set the vision stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseLesserMinion(1, {d: 1, s: 1, h: 1, v: 3, m: 1, r: 1})
				expect(boughtMinion.vision).toBeGreaterThan(minion.vision)
			it 'should set the mining stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseLesserMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 3, r: 1})
				expect(boughtMinion.mining).toBeGreaterThan(minion.mining)
			it 'should set the range stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseLesserMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 3})
				expect(boughtMinion.range).toBeGreaterThan(minion.range)
			it 'should set the can build flag to false', () ->
				boughtMinion = base.purchaseLesserMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(base.canBuild).toBeFalsy()

	describe 'purchaseGreaterMinion', () ->
		describe 'stat validation', () ->
			it 'should return null on undefined stats', () ->
				expect(base.purchaseGreaterMinion()).toBeNull()
			it 'should return a minion on valid stats', () ->
				ensureGold()
				minion = base.purchaseGreaterMinion(1, {d: 5, s: 1, h: 5, v: 1, m: 1, r: 1})
				expect(minion instanceof Minion).toBeTruthy()
			it 'should return null if canBuild is false', () ->
				ensureGold()
				base.canBuild = false
				expect(base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})).toBeFalsy()
			it 'should return null with too many stat points', () ->
				ensureGold()
				minion = base.purchaseGreaterMinion(1, {d: 10, s: 10, h: 1, v: 1, m: 1, r: 1})
				expect(minion).toBeNull()
		describe 'gold validation', () ->
			it 'should return null if dont have the gold', () ->
				base.gold = 0
				minion = base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(minion).toBeNull()
			it 'should not alter the gold if didnt buy', () ->
				minion = base.purchaseGreaterMinion(1, {d: 0, s: 1, h: 1, v: 1, m: 1, r: 1})
				checkGold(startingGold)
			it 'should alter the gold if bought', () ->
				ensureGold()
				gold = base.gold
				minion = base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})
				checkGold(gold - GameRules.building.costOfGreaterMinion)
		describe 'created minion', () ->
			it 'should set the attack stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseGreaterMinion(1, {d: 3, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(boughtMinion.damage).toBeGreaterThan(minion.damage)
			it 'should set the speed stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseGreaterMinion(1, {d: 1, s: 3, h: 1, v: 1, m: 1, r: 1})
				expect(boughtMinion.speed).toBeGreaterThan(minion.speed)
			it 'should set the health stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 3, v: 1, m: 1, r: 1})
				expect(boughtMinion.health).toBeGreaterThan(minion.health)
			it 'should set the vision stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 1, v: 3, m: 1, r: 1})
				expect(boughtMinion.vision).toBeGreaterThan(minion.vision)
			it 'should set the mining stat', () ->
				minion = new Minion(2, 1, 1, 1, 1, 1, 1)
				boughtMinion = base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 3, r: 1})
				expect(boughtMinion.mining).toBeGreaterThan(minion.mining)
			it 'should set the can build flag to false', () ->
				boughtMinion = base.purchaseGreaterMinion(1, {d: 1, s: 1, h: 1, v: 1, m: 1, r: 1})
				expect(base.canBuild).toBeFalsy()

	describe 'statsAreValid', () ->
		it 'should return false with an extra stat points', () ->
			expect(base.statsAreValid({d: 1, s: 2, h: 1, v: 3, m: 3, r: 1 }, 10)).toBeFalsy()
		it 'should return false if missing a stat', () ->
			expect(base.statsAreValid({d: 1, s: 2, h: 1, v: 3, m: 1 }, 10)).toBeFalsy()
		it 'should return false if stats are undefined', () ->
			expect(base.statsAreValid(undefined, 10)).toBeFalsy()
		it 'should return false if stats are null', () ->
			expect(base.statsAreValid(null, 10)).toBeFalsy()
		it 'should return true if stats are valid', () ->
			expect(base.statsAreValid({d: 1, s: 2, h: 1, v: 3, m: 1, r: 1 }, 10)).toBeTruthy()

	describe 'turnOver', () ->
		it 'should reset canBuild', () ->
			base.canBuild = false
			base.turnOver()
			expect(base.canBuild).toBeTruthy()
		
		