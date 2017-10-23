GameRules = require '../settings/gameRules'
Minion = require './minion'

class Base
	#(x, y) is the coordinate of the upper left cell of the base
	constructor: (@id, @x, @y) ->
		@gold = GameRules.base.startingGold
		@health = GameRules.base.startingHealth
		@size = GameRules.base.size
		@canBuild = true

	#causes the base to take damage
	#returns true if this damage killed the base
	applyDamage: (damage) ->
		@health -= Math.max damage, 0
		return @health <= 0

	#returns true if the base has vision of a certain cell
	canSeeCell: (x, y) ->
		return @distanceFromBase(x, y) <= GameRules.base.vision

	#returns the distance in number of cells from the base
	#a cell touching the base with an edge has a distance of 1
	#cells cornering the base have a distance of 2
	distanceFromBase: (x, y) ->
		xDist = 0
		if x < @x
			xDist = @x - x
		else if x > @x + @size - 1
			xDist = x - @x - @size + 1
		yDist = 0
		if y < @y
			yDist = @y - y
		else if y > @y + @size - 1
			yDist = y - @y - @size + 1
		return xDist + yDist

	#returns a list of all cells that the base sits on
	getCellsOccupied: () ->
		cells = []
		for cellY in [0...@size]
			for cellX in [0...@size]
				cells.push
					x: @x + cellX
					y: @y + cellY
		return cells

	#adds gold deposited by a minion
	goldDeposited: (gold) ->
		@gold += Math.max gold, 0
	
	#returns true if the base is alive
	isAlive: () ->
		return @health > 0

	#subtracts the cost of a purchase from the bases total
	#returns true if the purchase was made
	makePurchase: (cost) ->
		return false if cost < 0
		return false if @gold < cost
		
		@canBuild = false
		@gold -= cost
		return true

	#returns true if the base sits on a certain cell
	occupiesCell: (x, y) ->
		0 <= x - @x < @size and 0 <= y - @y < @size

	#commands the base to create and purchase a lesser minion with given stats
	purchaseLesserMinion: (id, stats) ->
		return null if not @canBuild
		return null if not @statsAreValid stats, GameRules.building.lesserMinionStats

		try
			minion = new Minion(id, stats.s, stats.d, stats.h, stats.v, stats.m, stats.r)
		catch
			return null

		return null if not @makePurchase(GameRules.building.costOfLesserMinion)
		return minion
		
	#commands the base to create and purchase a greater minion with given stats
	purchaseGreaterMinion: (id, stats) ->
		return null if not @canBuild
		return null if not @statsAreValid stats, GameRules.building.greaterMinionStats

		try
			minion = new Minion(id, stats.s, stats.d, stats.h, stats.v, stats.m, stats.r)
		catch
			return null

		return null if not @makePurchase(GameRules.building.costOfGreaterMinion)
		return minion

	#returns true if a stats object is valid and has a valid amount of points allocated
	statsAreValid: (stats, maxPoints) ->
		return false if stats is undefined
		return false if stats is null
		return false if stats.s is undefined
		return false if stats.d is undefined
		return false if stats.h is undefined
		return false if stats.v is undefined
		return false if stats.m is undefined
		return false if stats.r is undefined

		total = 0
		numStats = 0
		for own id, val of stats
			total += val
			numStats++
		return false if numStats != 6
		return false if total > maxPoints

		return true

	#called when the bases team is done issuing commands
	#resets flags
	turnOver: () ->
		@canBuild = true
		@gold += GameRules.base.goldPerTurn
		

module.exports = Base