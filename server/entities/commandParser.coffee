Board = require '../entities/board'
Command = require '../game/command'
Constants = require '../settings/constants'
Team = require '../entities/team'

#parses commands and calls appropriate methods on the boards
class CommandParser
	constructor: (@team, @board) ->

	#returns true if a command object contains a valid command name with valid parameters
	paramsAreValid: (command) ->
		return false if command.params is undefined
		return false if command.params is null

		switch command.commandName
			when Constants.commandsAttack
				return false if command.objectId is undefined
				return false if command.params.x is undefined
				return false if command.params.y is undefined
			when Constants.commandsBuildLesserMinion, Constants.commandsBuildGreaterMinion
				return false if command.params.x is undefined
				return false if command.params.y is undefined
				return false if command.params.stats is undefined
			when Constants.commandsHandOff
				return false if command.objectId is undefined
				return false if command.params.objectId is undefined
			when Constants.commandsMineResource
				return false if command.objectId is undefined
				return false if command.params.x is undefined
				return false if command.params.y is undefined
			when Constants.commandsMoveMinion
				return false if command.objectId is undefined
				return false if command.params.direction is undefined
		return true

	#parses a command and executes it for the given team
	#returns true if the command was successfully completed
	parse: (team, command) ->
		return false if command not instanceof Command
		return false if team not instanceof Team
		return false if not @paramsAreValid command

		switch command.commandName
			when Constants.commandsAttack then return @board.executeAttack(team, command.objectId, command.params.x, command.params.y)
			when Constants.commandsBuildLesserMinion then return @board.executeBuild(team, Constants.lesserMinionName, command.params.x, command.params.y, command.params.stats)
			when Constants.commandsBuildGreaterMinion then return @board.executeBuild(team, Constants.greaterMinionName, command.params.x, command.params.y, command.params.stats)
			when Constants.commandsHandOff then return @board.executeHandOff(team, command.objectId, command.params.objectId)
			when Constants.commandsMineResource then return @board.mineResource(team, command.objectId, command.params.x, command.params.y)
			when Constants.commandsMoveMinion then return @board.moveMinion(team, command.objectId, command.params.direction)
			else return false

module.exports = CommandParser