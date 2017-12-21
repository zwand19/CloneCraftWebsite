Constants =
	building:
		lesserMinionName:				'lesser minion'		# the lesser minions name
		greaterMinionName:				'greater minion'	# the greater minions name
	commands:
		attack:							'attack'			# the attack command name
		buildLesserMinion:				'build lesser'		# the build lesser minion command name
		buildGreaterMinion:				'build greater'		# the build greater minion command name
		handOff:						'hand off'			# the hand off resource command name
		mineResource:					'mine'				# the mine a resource command name
		moveMinion:						'move'				# the move command name
	tournament:
		bracketGamesPerMatch:			5					# the length of each series in a bracket tournament (best of x)
		roundRobinGamesPerMatch:		1#4 - temp set to 1 for debugging # the number of games to be played match in a round robin tournament
		maxTeamNameLength:				25					# the maximum number of characters in a team's name
		requestTimeout:					2000				# the amount of time given to an AI to respond before timing out
		
module.exports = Constants