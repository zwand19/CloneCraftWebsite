Path = require 'path'
port = process.env.PORT ? 6108
baseFolder = Path.join __dirname, '../', '/dist'
Logger = require './utilities/logger'

Logger.log "Initializing server at #{baseFolder} on port #{port}... #{new Date()}"

# Set up the server
Logger.info 'Creating http server...'
Express = require 'express'
app = Express()
httpsServer = require('http').createServer(app).listen port
Logger.info 'Server created!'

# Require modules
Logger.info 'Requiring modules...'
BodyParser = require 'body-parser'
Config = require './config.json'
ErrorHandler = require 'errorhandler'
Morgan = require 'morgan'
Helpers = require './helpers'
Routes = require './routes'
SocketIOCommunication = require './socketIOCommunication'
Standings = require './standings/standings'
TournamentScheduler = require './utilities/tournamentScheduler'
Logger.info 'Modules required!'

# configure express options
app.use Morgan 'dev'
if process.env.NODE_ENV is 'development'
	app.use ErrorHandler()
app.use BodyParser.json()
app.use BodyParser.urlencoded extended: true
app.use '/public', Express.static baseFolder
Routes app,
	base: baseFolder
	port: port

# set up socket IO to talk to clients
Logger.info 'Setting up socket IO communication...'
SocketIOCommunication.setup(httpsServer)
# initialize our db cache
Logger.info 'Loading standings cache...'
Standings.initialize()
.then ->
	# schedule weekly tournaments
	TournamentScheduler.scheduleTournament(Config.tournament_time)
	Logger.log 'Server good to go!'
.catch (err) ->
	Logger.error 'Could not start server properly'
	Logger.error err
	process.exit(1)

module.exports = httpsServer