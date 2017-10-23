#a very simple class representing a resource object
class Resource
	constructor: (@id) ->
		@onBoard = false

	#returns true if a resource is on the board and able to be mined
	isActive: () ->
		@onBoard

	#called when a minion has mined this resource
	mined: () ->
		@onBoard = false

	#updates the minions position
	placed: (@x, @y) ->
		@onBoard = true

	#called when a team has finished issuing commands
	turnElapsed: () ->
			
module.exports = Resource