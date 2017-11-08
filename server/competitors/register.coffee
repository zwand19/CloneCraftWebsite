Authentication = require '../authentication'
Config = require '../config.json'
Gravatar = require 'gravatar'
Helpers = require '../helpers'
Logger = require '../utilities/logger'
MailService = require '../utilities/emailService'
Messaging = require '../messaging'
Mongo = require '../utilities/mongoClient'
Path = require 'path'
Q = require 'q'

reservedNames = [ 'DRAW', 'WINNER', 'LOSER', 'MATCH', 'COMPETITOR', 'TOURNAMENT' ]
botTypes = [ 'C-Sharp', 'Node' ]
invalidUsernameCharacters = [ '.', '/', '\\', '*', ':', '<', '>', '?', '!', '@', '#', '|', '"', '\'']

class Register
	#---------------
	# Public Methods
	#---------------
	register: (email, username, password, apiUrl) ->
		validateRegistration(email, username, password, apiUrl)
		.then ->
			#ensure no competitor with email or username already
			Mongo.getCompetitor({ $or: [{email: email}, {name: username}]})
		.then (competitor) ->
			#check if we found a user
			if competitor
				if competitor.email is email
					Logger.info "competitor already found with email #{email}"
					throw new Error Messaging.Registration.EmailExists
				Logger.info "competitor already found with username #{username}"
				throw new Error Messaging.Registration.UsernameExists
			confirmationStr = Helpers.createRandomString 'xxxxxxxxxxxxxxxxxxxxxxxxxxx'
			salt = Helpers.createRandomString 'xxxxxxxxxxxxxxx'
			hashedPassword = Authentication.hashPassword password, salt
			competitor =
				name: username
				email: email
				confirmed: false
				confirmation_string: confirmationStr
				api_url: apiUrl
				registered_on: Helpers.getTimeStamp()
				gravatar: Gravatar.url(email, { s: '350', d: 'mm' }, true)
				uploads: 0
				gold_mined: 0
				game_wins: 0
				game_losses: 0
				match_wins: 0
				match_losses: 0
				match_draws: 0
				minions_killed: 0
				miners_built: 0
				archers_built: 0
				seers_built: 0
				foxes_built: 0
				tanks_built: 0
				greater_minions_built: 0
				lesser_minions_built: 0
				blurb: ''
				salt: salt
				password: hashedPassword
			Mongo.addCompetitor(competitor)
			.then (competitor) ->
				Logger.log "competitor #{competitor.name} added to database. sending registration email", competitor
				MailService.sendRegistrationEmail(competitor.confirmation_string, email)
			.catch (err) ->
				Logger.error "Could not send registration email to #{competitor.name}"
				Logger.error err
				throw new Error Messaging.Registration.EmailNotSent

	#----------------
	# Private Methods
	#----------------
	# Throw error if email, username, or api url is invalid
	validateRegistration = (email, username, password, apiUrl) ->
		# validate email
		if not email
			return Helpers.promisedError new Error Messaging.Registration.ProvideEmail
		# validate username
		if not username or username.length < 3 or username.length > 20
			return Helpers.promisedError new Error Messaging.Registration.UsernameLength
		if reservedNames.indexOf(username.toUpperCase()) isnt -1
			return Helpers.promisedError new Error Messaging.Registration.UsernameReserved
		if username.indexOf(' ') isnt -1
			return Helpers.promisedError new Error Messaging.Registration.UsernameContainsSpace
		for character in invalidUsernameCharacters
			if username.indexOf(character) isnt -1
				Logger.info "username #{username} contains invalid character #{character}"
				return Helpers.promisedError new Error Messaging.Registration.UsernameInvalidCharacter
		if username.toUpperCase() is 'KING'
			return Helpers.promisedError new Error Messaging.Registration.UsernameReserved
		# validate password
		if not password or password.length < 6 or password.length > 20
			return Helpers.promisedError new Error Messaging.Registration.PasswordLength
		if password.indexOf(' ') isnt -1
			return Helpers.promisedError new Error Messaging.Registration.PasswordContainsSpace
		for character in invalidUsernameCharacters
			if username.indexOf(character) isnt -1
				return Helpers.promisedError new Error Messaging.Registration.PasswordInvalidCharacter
		return Helpers.promisedData()
		# validate api url
		if not apiUrl or apiUrl.indexOf("http") < 0 or apiUrl.indexOf("://") < 0
			return Helpers.promisedError new Error Messaging.Registration.ApiUrl
		return Helpers.promisedData()

module.exports = new Register()