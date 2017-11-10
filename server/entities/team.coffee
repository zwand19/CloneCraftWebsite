GameRules = require '../settings/gameRules'

# Represents a competitor for 1 game
class Team
	constructor: (@id, @name, @api_url, @type) ->
		@base = null
		@goldMined = 0
		@minions = {}
		#used just for stat keeping
		@stats =
			minionsKilled: 0
			greaterMinionsBuilt: 0
			lesserMinionsBuilt: 0
			tanksBuilt: 0
			archersBuilt: 0
			seersBuilt: 0
			gruntsBuilt: 0
			minersBuilt: 0
			foxesBuilt: 0
		
	#adds a minion to a teams minion lookup object
	addMinion: (minion) ->
		# set attack stat to damage plus range. if they put no points in either then set to 1
		attackStat = minion.d + minion.r
		if attackStat is 2 then attackStat = 1
		max = Math.max(minion.s, attackStat, minion.h, minion.v, minion.m)
		numWithMax = 0
		if minion.s is max then numWithMax++
		if attackStat is max then numWithMax++
		if minion.h is max then numWithMax++
		if minion.v is max then numWithMax++
		if minion.m is max then numWithMax++
		# if no one stat is greater than others then it is a grunt
		if numWithMax > 1 then @stats.gruntsBuilt++
		else
			if minion.s is max then @stats.foxesBuilt++
			if attackStat is max then @stats.archersBuilt++
			if minion.h is max then @stats.tanksBuilt++
			if minion.v is max then @stats.seersBuilt++
			if minion.m is max then @stats.minersBuilt++
		isGreater = minion.s + attackStat + minion.h + minion.v + minion.m > 10
		if isGreater then @stats.greaterMinionsBuilt++ else @stats.lesserMinionsBuilt++
		minion.team = this
		@minions[minion.id] = minion

	#called when this teams base has been killed
	#converts all of this teams minions to the team that killed the base
	baseKilled: (killingTeam) ->
		@base = null
		#uncomment to convert minions to killing team
		#killingTeam.addMinion minion for own id, minion of @minions
		#@minions = {}

	#returns a minion by id
	getMinion: (id) ->
		return @minions[id]

	#returns true if the team is at the maximum amount of minions
	hasMaxMinions: () ->
		return Object.keys(@minions).length is GameRules.teamMaxMinions

	#removes a minion from the minion lookup object
	minionKilled: (id) ->
		delete @minions[id]

	#sets the teams base object
	setBase: (base) ->
		this.base = base
		base.team = this

	#called when the team has finished issuing commands
	#passes on the event to the teams minions and base
	turnOver: () ->
		@base.turnOver()
		for own id, minion of @minions
			minion.turnOver()

module.exports = Team