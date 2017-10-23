#Represents an AI competing in a tournament
class Competitor
	constructor: (@id, @name, @address, @gravatar) ->
		@inMatch = false
		@matches = []
		@matchIndex = 0
		@minionsKilled = 0
		@greaterMinionsBuilt = 0
		@lesserMinionsBuilt = 0
		@foxesBuilt = 0
		@tanksBuilt = 0
		@gruntsBuilt = 0
		@archersBuilt = 0
		@seersBuilt = 0
		@minersBuilt = 0
		@goldMined = 0

	# adds another opponent to invite to a game
	addMatch: (competitor) ->
		@matches.push competitor
		
	# sets our flag that we are not in a game
	finishedMatch: () ->
		@inMatch = false

	# we have started our next match, increment our index to look for a new opponent next time
	foundMatch: () ->
		@matchIndex++;

	# return the next opponent in the list to play
	# return null if we or the opponent are in a game or we have played all of our games
	getOpponent: () ->
		return null if @matchIndex >= @matches.length
		return null if @inMatch
		return null if @matches[@matchIndex].inMatch
		return @matches[@matchIndex]

	# randomly shuffle the list using the Fisher-Yates Shuffle
	shuffleMatches: () ->
		counter = @matches.length
		while counter--
			index = (Math.random() * counter) | 0

			temp = @matches[counter]
			@matches[counter] = @matches[index]
			@matches[index] = temp

	# returns true if there are still games needed to be played
	stillHasGames: () ->
		return @matchIndex < @matches.length or @inMatch

	# sets our flag that we are in a game
	startedMatch: () ->
		@inMatch = true

module.exports = Competitor