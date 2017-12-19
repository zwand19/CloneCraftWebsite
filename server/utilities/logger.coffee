Config = require '../config.json'
FS = require 'fs'
Mkdirp = require 'mkdirp'
Path = require 'path'

class Logger
	constructor: () ->
		Mkdirp Path.join(__dirname, '../../', logFolder), (err) ->
			if err
				console.error 'ERROR CREATING LOG FOLDER'
				console.error err
	#----------------
	# Private methods
	#----------------
	logFolder = 'logs'

	doLogging = (msg, metadata, consoleFunction, severity, filePath) ->
		try
			metadataString = ''
			if metadata then metadataString = JSON.stringify require('util').inspect(metadata, {depth: null}), null, ''
			#write to console
			if consoleFunction
				consoleFunction msg
				if metadata then consoleFunction require('util').inspect(metadata, {depth: null})
			#write to log Path
			timeStamp = require('../helpers').getTimeStamp()
			text = "(#{timeStamp}) #{severity}: #{msg}\n"
			text += "metadata: #{metadataString}\n" if metadata
			### COMMENTING OUT TO ONLY WRITE TO FULL_LOG TO SAVE MONEY FOR NOW
			FS.exists filePath, (exists) ->
				if exists
					FS.appendFile filePath, text, (err) ->
						if err
							console.error "ERROR APPENDING TO FILE #{filePath}"
							console.error err
				if not exists
					FS.writeFile filePath, text, (err) ->
						if err
							console.error "ERROR CREATING FILE #{filePath}"
							console.error err
			###
			fullLogPath = getFilePath "full_log.txt"
			FS.exists fullLogPath, (exists) ->
				if exists
					FS.appendFile fullLogPath, text, (err) ->
						if err
							console.error "ERROR APPENDING TO FILE #{fullLogPath}"
							console.error err
				if not exists
					FS.writeFile fullLogPath, text, (err) ->
						if err
							console.error "ERROR CREATING FILE #{fullLogPath}"
							console.error err
		catch logError
			console.error "LOGGER FATAL ERROR: #{logError}"

	getCompetitorFilePath = (fileName) ->
		Path.join __dirname, '../../', logFolder, 'Competitors', fileName

	getFilePath = (fileName) ->
		Path.join __dirname, '../../', logFolder, fileName

	#---------------
	# Public Methods
	#---------------
	competitorLog: (competitorName, msg, metadata) ->
		doLogging msg, metadata, (->), competitorName.toUpperCase(), getCompetitorFilePath "#{competitorName}.txt"
		
	competitorLogError: (competitorName, msg, metadata) ->
		doLogging 'ERROR: ' + msg, metadata, (->), competitorName.toUpperCase(), getCompetitorFilePath "#{competitorName}.txt"

	logApiError: (error, address, gameStatus) ->
		if Config.log_api_failures
			if not Config.log_api_failure_game_statuses then gameStatus = null
			doLogging address + ' ' + error, gameStatus, null, 'API FAILURE', getFilePath 'api_failures.txt'

	info: (msg, metadata) ->
		doLogging msg, metadata, console.info, 'INFO', getFilePath 'info.txt'

	log: (msg, metadata) ->
		doLogging msg, metadata, console.log, 'LOG', getFilePath 'log.txt'

	warn: (msg, metadata) ->
		doLogging msg, metadata, console.warn, 'WARN', getFilePath 'warn_log.txt'

	error: (msg, metadata, err) ->
		doLogging msg, metadata, console.error, 'ERROR', getFilePath 'error_log.txt'
		if err then doLogging err, '', console.error, 'ERROR', getFilePath 'error_log.txt'
		err

module.exports = new Logger()