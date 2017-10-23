Board = require '../entities/board'
Constants = require '../settings/constants'
Team = require '../entities/team'

#parses commands and calls appropriate methods on the boards
class CommandParser
	constructor: (@team, @board) ->

	#returns true if a command object contains a valid command name with valid parameters
	paramsAreValid: (command) ->
		return false if command is undefined
		return false if command is null
		return false if command.params is undefined
		return false if command.params is null

		switch command.commandName
			when Constants.commands.attack
				return false if command.minionId is undefined
				return false if command.params.x is undefined
				return false if command.params.y is undefined
			when Constants.commands.buildLesserMinion, Constants.commands.buildGreaterMinion
				return false if command.params.x is undefined
				return false if command.params.y is undefined
				return false if command.params.stats is undefined
			when Constants.commands.handOff
				return false if command.minionId is undefined
				return false if command.params.minionId is undefined
			when Constants.commands.mineResource
				return false if command.minionId is undefined
				return false if command.params.x is undefined
				return false if command.params.y is undefined
			when Constants.commands.moveMinion
				return false if command.minionId is undefined
				return false if command.params.direction is undefined
			else return false
		return true

	#parses a command and executes it for the given team
	#returns true if the command was successfully completed
	parse: (command) ->
		return false if @team not instanceof Team
		return false if @board not instanceof Board
		return false if not @paramsAreValid command

		switch command.commandName
			when Constants.commands.attack then return @board.executeAttack(@team, command.minionId, command.params.x, command.params.y)
			when Constants.commands.buildLesserMinion then return @board.executeBuild(@team, Constants.building.lesserMinionName, command.params.x, command.params.y, command.params.stats)
			when Constants.commands.buildGreaterMinion then return @board.executeBuild(@team, Constants.building.greaterMinionName, command.params.x, command.params.y, command.params.stats)
			when Constants.commands.handOff then return @board.executeHandOff(@team, command.minionId, command.params.minionId)
			when Constants.commands.mineResource then return @board.mineResource(@team, command.minionId, command.params.x, command.params.y)
			when Constants.commands.moveMinion then return @board.moveMinion(@team, command.minionId, command.params.direction)
			else return false

module.exports = CommandParser