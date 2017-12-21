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
		res.sendFile "#{options.base}/index.html"

	app.get "/competitors/:name", (req, res) ->
		competitorName = req.params.name
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
		res.json { success: true, data: Standings.getTournamentNames() }

	app.get "/tournaments/:id", (req, res) ->
		tournamentId = req.params.id
		Standings.getTournament(tournamentId)
		.then (details) ->
			res.json { success: true, data: details }
		.catch (err) ->
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.get "/tournaments-general", (req, res) ->
		Standings.getGlobalDetails()
		.then (details) ->
			res.json { success: true, data: details }
		.catch (err) ->
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	#-------------
	# POST Methods
	#-------------
	app.post "/confirm/:id", (req, res) ->
		confirmationString = req.params.id
		Confirm.confirm(confirmationString)
		.then (result) ->
			res.json { success: true, uploadId: result.uploadId, msg: result.msg }
		.catch (err) ->
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.post "/login", (req, res) ->
		credential = req.body.data.credential
		password = req.body.data.password
		Authentication.authenticateLogin(credential, password)
		.then (result) ->
			res.json
				success: true
				username: result.username
				token: result.token
		.catch (err) ->
			Logger.info err
			res.json
				success: false
	
	app.post "/register", (req, res) ->
		email = req.body.data.email
		username = req.body.data.username
		password = req.body.data.password
		api_url = req.body.data.api_url
		Logger.info "incoming registration request #{username} with email address #{email} and api URL #{api_url}"
		Register.register(email, username, password, api_url)
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

	app.get "/run", (req, res) ->
		username = Authentication.authenticateRequest req, res
		if username is "zwand"
			TournamentScheduler.runTournament()
			.then ->
				res.send(200)
			.catch ->
				res.send(500, "tournament not run")
		else res.send 500, "only an admin can run a tournament"

	app.get "/temp-super-secret-run-url", (req, res) ->
		TournamentScheduler.runTournament()
		.then ->
			res.send(200)
		.catch ->
			res.send(500, "tournament not run")

	app.post "/updateProfile", (req, res) ->
		username = Authentication.authenticateRequest req, res
		if not req.body
			return res.json { success: false, msg: Messaging.handleErrorMessage Messaging.ServerError }
		Profile.updateProfile(username, req.body)
		.then ->
			res.json { success: true }
		.catch (err) ->
			res.json
				success: false
				msg: Messaging.handleErrorMessage err.message

	app.use (req, res, next) ->
	    err = new Error 'Not Found'
	    err.status = 404
	    next err