exports.AttackCommand = class AttackCommand
	constructor: (@minionId, x, y) ->
		@commandName = 'attack'
		@params =
			x: x
			y: y
			
exports.BuildLesserMinionCommand = class BuildLesserMinionCommand
	constructor: (damageStat, rangeStat, healthStat, miningStat, speedStat, visionStat, x, y) ->
		# stats can equal up to 10
		if (damageStat + rangeStat + healthStat + miningStat + speedStat + visionStat) > 10
			console.error "WARN: Lesser Minion can only have up to 10 skill points!"
		@commandName = 'build lesser'
		@minionId = null
		@params =
			x: x
			y: y
			stats:
				d: damageStat
				r: rangeStat
				h: healthStat
				m: miningStat
				s: speedStat
				v: visionStat
				
exports.BuildGreaterMinionCommand =
	class BuildGreaterMinionCommand
		constructor: (damageStat, rangeStat, healthStat, miningStat, speedStat, visionStat, x, y) ->
			if (damageStat + rangeStat + healthStat + miningStat + speedStat + visionStat) > 19
				console.error "WARN: Greater Minion can only have up to 19 skill points!"
			@commandName = 'build greater'
			@minionId = null
			@params =
				x: x
				y: y
				stats:
					d: damageStat
					r: rangeStat
					h: healthStat
					m: miningStat
					s: speedStat
					v: visionStat
				
exports.HandOffCommand =
	class HandOffCommand
		constructor: (handerId, handeeId) ->
			@commandName = 'hand off'
			@minionId = handerId
			@params =
				minionId: handeeId
				
exports.MineCommand =
	class MineCommand
		constructor: (@minionId, x, y) ->
			@commandName = 'mine'
			@params =
				x: x
				y: y
			
exports.MoveCommand =
	class MoveCommand
		constructor: (@minionId, direction) ->
			@commandName = 'move'
			if ['N', 'S', 'E', 'W'].indexOf(direction) == -1
				console.error "WARN: #{direction} is not a valid direction!"
			@params =
				direction: direction

exports.Commands =
	class Commands
		constructor: (someCommands) ->
			@commandsArray = []
			@append = (someCommands) ->
				if Array.isArray someCommands
					for aCommand in someCommands
						@append aCommand # recurse
				else if someCommands != null && typeof someCommands == 'object'
					if someCommands.commandName
						@commandsArray.push someCommands
					else if someCommands.commandsArray # can append Commands classes together.
						@append someCommands.commandsArray
					else
						console.error "WARN: cannot append commands. Not an recognized object!"
				else
					console.error "WARN: cannot append commands. Not an array or object!"
			@stringify = ->
				JSON.stringify @commandsArray
			@debug = (otherText = "") ->
				console.log "<-- DEBUG COMMANDS #{otherText} -->"
				console.log JSON.stringify @commandsArray, null, 4
				console.log "</- DEBUG COMMANDS #{otherText} -/>"
				