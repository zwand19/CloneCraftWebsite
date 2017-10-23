Base = require './base'
Constants = require '../settings/constants'
GameRules = require '../settings/gameRules'
Helpers = require '../helpers'
Minion = require './minion'
Resource = require './resource'
Team = require './team'

# holds all pieces in the game and has functions to manipulate them
# holds most of the game logic
class Board
	constructor: (@id, @width, @height) ->
		@height = @width if @height is undefined
		@bases = []
		@minions = []
		@resources = []
		@nextId = 1
		# set up an empty grid
		@grid = []
		for rowId in [0...@height]
			row = []
			@grid.push row
			for colId in [0...@width]
				row.push
					obj: null

	# returns true if the (x, y) coordinate is on the board and does not contain an object
	cellIsUnoccupiedAndValid: (x, y) ->
		for minion in @minions
			return false if minion.x is x and minion.y is y
		return @getObjectAt(x, y) is null

	# can move over empty spaces, your own base, or resources
	cellIsMoveable: (x, y, team) ->
		# cannot move over minions
		for minion in @minions
			return false if minion.x is x and minion.y is y
		# check board objects
		obj = @getObjectAt(x, y)
		return true if obj is null
		return true if obj instanceof Resource
		return true if obj is team.base
		return false

	# commands a minion to attack a cell
	executeAttack: (team, minionId, x, y) ->
		return false if team not instanceof Team
		minion = team.getMinion minionId
		return false if minion not instanceof Minion

		target = null
		for m in @minions
			if m.x is x and m.y is y
				target = m
		if target is null
			target = @getObjectAt x, y

		return false if not minion.attack target
		return true if target.isAlive()

		# if we killed a minion remove it from lists
		if target instanceof Minion
			target.team.minionKilled target.id
			team.stats.minionsKilled++
			@minions = @minions.filter (m) ->
				m isnt target
		# if we killed a base clear all of its cells and remove it from lists
		else if target instanceof Base
			for cell in target.team.base.getCellsOccupied()
				@setObjectAt cell.x, cell.y, null
			target.team.baseKilled(team)
			@bases = @bases.filter (b) ->
				b isnt target

		true

	# commands a base to build a certain type of minion at a certain location with certain stats
	executeBuild: (team, minionName, x, y, stats) ->
		return false if team not instanceof Team
		return false if team.base not instanceof Base
		cell = @getObjectAt x, y
		return false if cell is undefined
		return false if cell instanceof Base
		return false if cell instanceof Minion
		nextToMinion = false
		# check if building next to other minions
		for id, minion of team.minions
			minionCell =
				x: minion.x,
				y: minion.y
			cell =
				x: x
				y: y
			if Helpers.distanceBetween(minionCell, cell) is 1
				nextToMinion = true
		return false if not nextToMinion and team.base.distanceFromBase(x, y) > 1
		return false if team.hasMaxMinions()
		# check what minion they are trying to build
		switch minionName
			when Constants.building.lesserMinionName then minion = team.base.purchaseLesserMinion @nextId, stats
			when Constants.building.greaterMinionName then minion = team.base.purchaseGreaterMinion @nextId, stats
			else return false
		return false if minion is null

		# if we cant place the minion at that location refund their gold
		if not @placeMinion(team, minion, x, y)
			switch minionName
				when Constants.building.lesserMinionName then team.base.goldDeposited GameRules.building.costOfLesserMinion
				when Constants.building.greaterMinionName then team.base.goldDeposited GameRules.building.costOfGreaterMinion
			return false

		@nextId++
		true

	# command a minion to hand off their resources to another minion
	executeHandOff: (team, minion1Id, minion2Id) ->
		return false if team not instanceof Team

		minion1 = team.getMinion(minion1Id)
		minion2 = team.getMinion(minion2Id)
		return false if minion1 not instanceof Minion
		return false if minion2 not instanceof Minion

		success = minion1.handOffGold(minion2)
		if success
			# check if we are next to the base and deposit resources
			if team.base.distanceFromBase(minion2.x, minion2.y) <= 1
				team.base.goldDeposited minion2.carrying
				team.goldMined += minion2.carrying
				minion2.resetCarrying()
		success

	# get an object on the grid, or undefined if it is not a valid cell
	# minions are not kept on the grid
	getObjectAt: (x, y) ->
		return undefined if x is undefined or y is undefined
		return undefined if x < 0 or x >= @width or y < 0 or y >= @height
		@grid[y][x].obj

	# gets the list of all minions, bases, and resources that are visible for a team
	getVision: (team) ->
		vision = 
			minions: []
			bases: []
			resources: []

		for minion in @minions
			continue if minion.team is team
			minionInSight = false
			minionInSight = true if team.base.canSeeCell minion.x, minion.y
			for id, ownMinion of team.minions
				minionInSight = true if ownMinion.canSeeCell minion.x, minion.y
			vision.minions.push minion if minionInSight

		for base in @bases
			continue if base.team is team
			baseInSight = false
			for cell in base.getCellsOccupied()
				continue if baseInSight
				baseInSight = true if team.base.canSeeCell cell.x, cell.y
				for id, minion of team.minions
					baseInSight = true if minion.canSeeCell cell.x, cell.y
			vision.bases.push base if baseInSight
				
		for resource in @resources
			continue if not resource.isActive()
			canSeeResource = false
			canSeeResource = true if team.base.canSeeCell resource.x, resource.y
			for id, minion of team.minions
				canSeeResource = true if minion.canSeeCell resource.x, resource.y
			vision.resources.push resource if canSeeResource

		vision

	# gets the list of all minions, bases, and resources on the board
	getFullVision: (team) ->
		vision = 
			minions: []
			bases: []
			resources: []

		for minion in @minions
			continue if minion.team is team
			vision.minions.push minion

		for base in @bases
			continue if base.team is team
			vision.bases.push base
				
		for resource in @resources
			continue if not resource.isActive()
			vision.resources.push resource

		vision


	# commands a minion to mine at a certain location
	mineResource: (team, minionId, x, y) ->
		return false if team not instanceof Team
		
		minion = team.getMinion minionId
		return false if minion not instanceof Minion

		resource = @getObjectAt x, y
		return false if resource not instanceof Resource

		mined = minion.mine resource
		return false if not mined

		@setObjectAt resource.x, resource.y, null
		return true
	
	# commands a minion to move in a certain direction
	moveMinion: (team, minionId, direction) ->
		return false if direction not in ['N','S','E','W','n','s','e','w']
		return false if team not instanceof Team
		return false if team.base not instanceof Base

		minion = team.getMinion minionId
		return false if minion is undefined

		cellMovingTo =
			x: minion.x
			y: minion.y

		switch direction
			when 'N','n' then cellMovingTo.y--
			when 'S','s' then cellMovingTo.y++
			when 'E','e' then cellMovingTo.x++
			when 'W','w' then cellMovingTo.x--

		return false if not @cellIsMoveable cellMovingTo.x, cellMovingTo.y, team
		minionMoved = minion.moved cellMovingTo
		return false if not minionMoved

		# check if we are next to the base and deposit resources
		if team.base.distanceFromBase(minion.x, minion.y) <= 1
			team.base.goldDeposited minion.carrying
			team.goldMined += minion.carrying
			minion.resetCarrying()

		return true
		
	# creates and places a base on the board for a certain team	
	# returns true if the base is placed		
	placeBase: (team, x, y) ->
		return false if team not instanceof Team
		return false if team.base isnt null

		base = new Base @nextId, x, y

		baseCells = base.getCellsOccupied()

		for cell in baseCells
			return false if not @cellIsUnoccupiedAndValid cell.x, cell.y

		for cell in baseCells
			@setObjectAt cell.x, cell.y, base
		team.setBase base
		@bases.push base
		@nextId++
		true

	# places a minion at a certain location for a team
	# returns true if the minion is placed
	placeMinion: (team, minion, x, y) ->
		return false if minion not instanceof Minion or team not instanceof Team
		for m in @minions
			return false if m.x is x and m.y is y
		cell = @getObjectAt x, y
		if cell is null or cell instanceof Resource
			team.addMinion minion
			@minions.push minion
			minion.placed x, y
			return true
		false

	# creates and places a resource at a certain location
	# returns true if the resource is placed
	placeResource: (x, y) ->
		return false if not @cellIsUnoccupiedAndValid x, y
		for base in @bases
			return false if (base.distanceFromBase x, y) < GameRules.resources.minDistanceFromBase

		resource = new Resource @nextId
		resource.placed x, y
		@nextId++

		@grid[resource.y][resource.x].obj = resource
		@resources.push resource
		true

	# creates and places a list of resouces
	# returns true if the resources are placed
	# if any placement fails then none are placed
	placeResources: (list) ->
		# verify can place all
		for coord in list
			return false if not @cellIsUnoccupiedAndValid coord.x, coord.y
			for base in @bases
				return false if (base.distanceFromBase coord.x, coord.y) < GameRules.resources.minDistanceFromBase

		# place all resources
		for coord in list
			@placeResource coord.x, coord.y
		true


	# sets a certain cell's object
	# minions are not kept on the grid
	setObjectAt: (x, y, object) ->
		if 0 <= x < @width and 0 <= y < @height
			@grid[y][x].obj = object
				
module.exports = Board