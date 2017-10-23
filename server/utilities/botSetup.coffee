Config = require '../config.json'
Logger = require './logger'
Helpers = require '../helpers'
ShellCommandRunner = require './shellCommandRunner'
Path = require 'path'
Q = require 'q'

class BotSetup
	#---------------
	# Public Methods
	#---------------
	initializeCompetitor: (competitor, language) ->
		if not competitor or not competitor.name or not competitor.code_folder
			throw new Error('invalid competitor')

		codeFolder = Path.join './CompetitorCode/', competitor.name
		fnSetupBot = getBotSetupMethod language
		Logger.info "Initializing folder #{codeFolder}"
		Helpers.makeDirectoryRecursively(codeFolder)
			.catch (err) ->
				throw Logger.error("Could not create competitor code folder: #{codeFolder}", null, err)
			.then () ->
				Logger.info "Created code folder #{codeFolder}"
				fnSetupBot(competitor, codeFolder)
				
	#----------------
	# Private Methods
	#----------------
	getFullPath = (localPath) ->
		Path.join __dirname, '../../', localPath

	getBotSetupMethod = (language) ->
		switch language
			when 'C-Sharp'
				setupCSharpBot
			when 'Node'
				setupNodeBot
			else throw new Error('invalid language')

	setupCSharpBot = (competitor, codeFolder) ->
		Helpers.copyDirectoryRecursively("./StarterBots/c-sharp", codeFolder)
			.catch (err) ->
				throw Logger.error("Could not copy c-sharp starter bot into code folder: #{codeFolder}", null, err)
			.then () ->
				cloneCraftSitePath = getFullPath codeFolder
				scriptPath = getFullPath Config.script_execute_powershell
				params = [Config.script_create_iis_app, competitor.name, cloneCraftSitePath]
				ShellCommandRunner.execute(scriptPath, params, competitor.name)
			.catch (err) ->
				Logger.error "Could not start iis app #{competitor.name}"
				throw "Error creating iis app #{competitor.name}"
			.then () ->
				Logger.log "created iis app #{competitor.name}"
				true

	setupNodeBot = (competitor, codeFolder) ->
		Helpers.copyDirectoryRecursively("./StarterBots/node", codeFolder)
			.catch (err) ->
				throw Logger.error("Could not copy node starter bot into code folder: #{codeFolder}", null, err)
			.then () ->
				scriptPath = Path.join __dirname, '../../', Config.script_start_node_server
				nodePath = Path.join __dirname, '../../', competitor.code_folder
				params = [Config.server_disk, nodePath, competitor.port]
				Logger.log "Starting node supervisor for #{competitor.name}..."
				ShellCommandRunner.spawn scriptPath, params, competitor.name

module.exports = new BotSetup()