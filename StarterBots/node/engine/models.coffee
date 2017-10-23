exports.Base =
	class Base
		constructor: (@id, @gold, @health, @x, @y) ->
			@size = 3

exports.Minion =
	class Minion
		constructor: (@id, @x, @y, @gold, @damage, @health, @mining, @range, @speed, @vision) ->

exports.Resource =
	class Resource
		constructor: (@id, @x, @y) ->

exports.Status =
	class Status
		constructor: (status) ->
			if typeof status == "string" 
				status = JSON.parse status
			@round = status.round
			@boardWidth = status.board.w
			@boardHeight = status.board.h

			@nextMinionId = status.nextMinionId

			@minions = []
			for m in status.minions
				@minions.push new Minion(m.id, m.x, m.y, m.g, m.d, m.hp, m.mi, m.r, m.sp, m.vi)

			@enemyMinions = []
			for m in status.vision.minions
				@enemyMinions.push new Minion(m.id, m.g, m.d, m.hp, m.mi, m.r, m.sp, m.vi)

			@base = new Base(status.base.id, status.base.g, status.base.h, status.base.x, status.base.y)

			@enemyBase = null
			if status.vision.bases.length > 0
				b = status.vision.bases[0]
				@enemyBase = new Base(b.id, b.g, b.h, b.x, b.y)

			@resources = []
			for r in status.vision.resources
				@resources.push new Resource(r.id, r.x, r.y)
			
		@debug = (status, otherText) ->
			otherText = "(round #{status.round})" unless otherText
			console.log "<-- DEBUG STATUS #{otherText} -->"
			console.log JSON.stringify status, null, 4
			console.log "</- DEBUG STATUS #{otherText} -/>"

exports.Directions = 
	North: 'N'
	South: 'S'
	East: 'E'
	West: 'W'