Helpers = require '../helpers'
Logger = require '../utilities/logger'
Path = require 'path'
Q = require 'q'
Zipper = require '../utilities/zipper'

# Manages writing games/matches/tournaments to file so they can be replayed
class FileManager
	#---------------
	# Public Methods
	#---------------
	writeBracketMatchToFile: (match) ->
		writeMatchToFile(match, bracketFileNameResolver)
		.then () ->
			match
			
	writeRoundRobinMatchToFile: (match) ->
		writeMatchToFile(match, roundRobinFileNameResolver)
		.then () ->
			match

	#----------------
	# Private Methods
	#----------------
	# creates a file name for a game within a given bracket match
	bracketFileNameResolver = (match, gameIndex) ->
		"round #{(match.id.s + match.id.r - 1)} #{id} match #{(gameIndex + 1)} #{match.competitor1.name} vs. #{match.competitor2.name}"

	rejectInvalidMatch = (match) ->
		deferred = Q.defer()
		process.nextTick () ->
			Logger.error 'Could not write invalid match to file', match
			deferred.reject new Error 'Could not write invalid match to file'
		deferred.promise

	# creates a file name for a game within a given round robin match
	roundRobinFileNameResolver = (match, gameIndex) ->
		"game #{(gameIndex + 1)} #{match.competitor1.name} vs. #{match.competitor2.name}"

	# writes both types of matches to file, takes in a function to resolve the file
	writeMatchToFile = (match, nameResolverFunction) ->
		if not match.competitor1 or not match.competitor2 or not match.games or not match.folderPath
			return rejectInvalidMatch match, deferred
		promises = []
		for i in [0...match.games.length]
			#build contents of file
			gameInfo =
				game: match.gameInfos[i]
				statuses: match.statuses[i]
				version: "1.0"
			gameString = JSON.stringify gameInfo
			#determine path to file and fileName
			fileName = nameResolverFunction match, i
			matchPath = Path.join match.folderPath, fileName
			localPath = matchPath.substring(matchPath.indexOf('matches'))
			match.games[i].zipPath = "#{localPath}.zip"
			promises.push(Helpers.writeToClonecraftFile(matchPath, gameString)
				#.then (path) ->
				#	Zipper.zipAndDeleteFiles(["#{path}.clonecraft"], "#{path}.zip")
				.catch (err) ->
					Logger.error 'could not write file to zip', null, err
					throw err)
		Q.all(promises)
		
module.exports = new FileManager()