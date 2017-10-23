GameRules = require '../settings/gameRules'
Helpers = require '../helpers'
Resource = require './resource'

class Minion
	constructor: (@id, @s, @d, @h, @v, @m, @r) ->
		@setStat 'speed', @s, GameRules.minion.speed
		@setStat 'damage', @d, GameRules.minion.damage
		@setStat 'health', @h, GameRules.minion.health
		@setStat 'vision', @v, GameRules.minion.vision
		@setStat 'mining', @m, GameRules.minion.mining
		@setStat 'range', @r, GameRules.minion.range
		#initialize other properties
		@canAct = false
		@carrying = 0
		@movesRemaining = 0

	#---------------
	# Public Methods
	#---------------
	#causes this minion to take damage
	#returns true if the damage killed the minion
	applyDamage: (damage) ->
		@health -= Math.max damage, 0
		return @health <= 0

	#commands the minion to attack an object
	attack: (object) ->
		if not @isValidAttack(object)
			@canAct = false
			@movesRemaining = 0
			return false

		object.applyDamage(@damage)
		@canAct = false
		@movesRemaining = 0
		return true

	#returns true if a cell is in attack range
	canAttackCell: (x, y) ->
		@cellIsInRange(x, y, @range)

	#returns true if a cell is in vision range
	canSeeCell: (x, y) ->
		@cellIsInRange(x, y, @vision)

	#returns true if a cell is within a certain distance of the minion
	cellIsInRange: (cellX, cellY, range) ->
		distance = Helpers.distanceBetween(this,{x: cellX, y: cellY})
		return distance <= range

	#commands the minion to hand off its resources to another minion
	handOffGold: (minion) ->
		return false if minion not instanceof Minion
		return false if @carrying is 0
		return false if Helpers.distanceBetween(this, minion) isnt 1
		return false if @team isnt minion.team
		return false if minion.carrying isnt 0

		minion.carrying += @carrying
		@carrying = 0
		return true

	#returns true if the minion is alive
	isAlive: () ->
		return @health > 0

	#returns true if the object is valid to attack
	isValidAttack: (object) ->
		Base = require './base'
		return false if object not instanceof Minion and object not instanceof Base
		return false if not @canAct
		return false if object instanceof Minion and Helpers.distanceBetween(this, object) > @range
		return false if object instanceof Base and object.distanceFromBase(@x, @y) > @range
		return false if this is object
		return false if not object.isAlive()
		return false if object instanceof Base and object.team is @team
		return true

	#commands the minion to mine a resource object
	mine: (resource) ->
		return false if resource not instanceof Resource
		return false if Helpers.distanceBetween(this, resource) > 1
		return false if not resource.isActive()
		return false if not @canAct
		return false if @carrying isnt 0
		
		@canAct = false
		@movesRemaining = 0
		@carrying += @mining
		resource.mined()
		return true

	#called when a minion has been moved
	#updates the minions position and decrements its moves remaining
	moved: (newCell) ->
		return false if @movesRemaining is 0
		return false if Helpers.distanceBetween(this, newCell) != 1
		@x = newCell.x
		@y = newCell.y
		@movesRemaining--
		@canAct = false
		return true

	#updates a minions position
	placed: (@x, @y) ->

	#resets a minions resources to 0
	resetCarrying: () ->
		@carrying = 0

	#adds resources to the minion
	receiveResources: (resources) ->
		return if @carrying isnt 0
		@carrying += resources

	setStat: (property, stat, rule) ->
		if stat < 1 or stat > rule.max
			throw new Error 'Could not create minion, invalid stat point allocation'
		@[property] = rule.base + Math.floor stat * rule.per

	#called when the minions team is done issuing commands
	#resets flags
	turnOver: () ->
		@canAct = true
		@movesRemaining = @speed

module.exports = Minion