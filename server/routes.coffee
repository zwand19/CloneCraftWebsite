Authentication = require './authentication'
Competitor = require './game/competitor'
Confirm = require './competitors/confirm'
FS = require 'fs'
Logger = require './utilities/logger'
Match = require './game/match'
Messaging = require './messaging'
Profile = require './competitors/profile'
Register = require './competitors/register'
Standings = require './standings/standings'
TournamentScheduler = require './utilities/tournamentScheduler'
Path = require 'path'
Q = require 'q'

currentPlayer = 0

module.exports = (app, options) ->
	#------------
	# GET Methods
	#------------
	app.get "/", (req, res) ->
		Logger.info 'incoming request to get index.html'
		res.sendFile "#{options.base}/index.html"

	app.get "/competitors/:name", (req, res) ->
		competitorName = req.params.name
		Logger.info "incoming request for competitor #{competitorName}"
		Standings.getCompetitorDetails(competitorName)
		.then (details) ->
			Logger.info 'competitor request succeeded'
			res.json { success: true, data: details }
		.catch (err) ->
			Logger.info 'competitor request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.get "/competitors/:name/:tournamentId", (req, res) ->
		competitorName = req.params.name
		tournamentId = req.params.tournamentId
		Logger.info "incoming request for competitor's tournament detail #{competitorName} in #{tournamentId}"
		Standings.getCompetitorTournamentMatches(competitorName, tournamentId)
		.then (details) ->
			Logger.info 'competitor tournament detail request succeeded'
			res.json { success: true, data: details }
		.catch (err) ->
			Logger.info 'competitor tournament detail request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.get '/download', (req, res) ->
		try
			path = require('url').parse(req.url,true).query.path
			zipPath = Path.join __dirname, '../', path
			Logger.info "incoming request to download game file at #{zipPath}"

			zipSize = FS.statSync(zipPath).size

			res.header 'Content-Type', 'application/octet-stream'
			res.header 'Content-Length', zipSize

			readStream = FS.createReadStream zipPath
			readStream.pipe res
			Logger.info 'file downloaded'
		catch err
			Logger.error 'Error download game file'
			Logger.error err
			throw err

	app.get "/tournaments", (req, res) ->
		Logger.info 'incoming tournaments GET request'
		Logger.info 'request succeeded'
		res.json { success: true, data: Standings.getTournamentNames() }

	app.get "/tournaments/:id", (req, res) ->
		tournamentId = req.params.id
		Logger.info "incoming tournament details request for #{tournamentId}"
		Standings.getTournament(tournamentId)
		.then (details) ->
			Logger.info 'tournament details request succeeded'
			res.json { success: true, data: details }
		.catch (err) ->
			Logger.info 'tournament details request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.get "/tournaments-general", (req, res) ->
		Logger.info 'incoming request for general tournaments'
		Standings.getGlobalDetails()
		.then (details) ->
			Logger.info 'general tournaments request succeeded'
			res.json { success: true, data: details }
		.catch (err) ->
			Logger.info 'general tournaments request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	#-------------
	# POST Methods
	#-------------
	app.post "/confirm/:id", (req, res) ->
		confirmationString = req.params.id
		Logger.info "incoming confirmation request for #{confirmationString}"
		Confirm.confirm(confirmationString)
		.then (result) ->
			Logger.info 'confirmation request succeeded'
			res.json { success: true, uploadId: result.uploadId, msg: result.msg }
		.catch (err) ->
			Logger.info 'confirmation request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.post "/login", (req, res) ->
		credential = req.body.data.credential
		password = req.body.data.password
		Logger.info "incoming login request for #{credential}"
		Authentication.authenticateLogin(credential, password)
		.then (result) ->
			Logger.info "login successful for #{credential}"
			res.json
				success: true
				username: result.username
				token: result.token
		.catch (err) ->
			Logger.info "login failed for #{credential}"
			Logger.info err
			res.json
				success: false
	
	app.post "/register", (req, res) ->
		email = req.body.data.email
		username = req.body.data.username
		password = req.body.data.password
		language = req.body.data.language
		Logger.info "incoming registration request #{username} with email address #{email} and language #{language}"
		Register.register(email, username, password, language)
		.then ->
			Logger.info 'registration request succeeded'
			res.json
				success: true
				token: Authentication.getNewToken(username)
		.catch (err) ->
			Logger.info 'registration request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.post "/run", (req, res) ->
		username = Authentication.authenticateRequest req, res
		if username is "zwand"
			TournamentScheduler.runTournament()
			.then ->
				res.send(200)
			.catch ->
				res.send(500, "tournament not run")
		else res.send 500, "only an admin can run a tournament"

	app.post "/updateProfile", (req, res) ->
		username = Authentication.authenticateRequest req, res
		Logger.info "incoming update profile request for #{username}"
		if not req.body
			return res.json { success: false, msg: Messaging.handleErrorMessage Messaging.ServerError }
		Profile.updateProfile(username, req.body)
		.then ->
			Logger.info 'update profile request succeeded'
			res.json { success: true }
		.catch (err) ->
			Logger.info 'update profile request failed'
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.use (req, res, next) ->
	    err = new Error 'Not Found'
	    err.status = 404
	    next err