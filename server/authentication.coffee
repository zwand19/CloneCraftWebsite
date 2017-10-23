Config = require './config.json'
Crypto = require 'crypto'
Helpers = require './helpers'
Mongo = require './utilities/mongoClient'

class Authentication
	encryptionAlgorithm = 'aes192'
	hashingAlgorithm = 'sha512'

	#---------------
	# Public Methods
	#---------------

	# Authenticates an email or username and password against db. returns encrypted token if valid
	authenticateLogin: (credential, password) ->
		_this = @
		Mongo.getCompetitor({ $or: [{email: credential}, {name: credential}]}, { email: true, name: true, password: true, salt: true })
		.catch (err) ->
			Logger.error "DB Error: Could not get user #{credential} for authentication"
			Logger.error err
			throw err
		.then (user) ->
			if not user
				throw new Error "could not find user #{credential}"
			encodedPassword = _this.hashPassword password, user.salt
			if encodedPassword isnt user.password
				throw new Error "invalid password for #{credential}"
			token = _this.getNewToken user.name
			return {
				username: user.name
				token: token
			}

	# Checks an http request for its authentication header
	# If the request is not authorized then send http response and throw error
	# Return username if authorized
	authenticateRequest: (req, res) ->
		failure = ->
			res.send 401
			throw new Error 'Unauthorized request'
		if not req.headers.authtoken then failure()
		username = @authenticateToken req.headers.authtoken
		if not username then failure()
		username

	# Return username if the encrypted token is valid
	authenticateToken: (tokenString) ->
		try
			token = decrypt tokenString
		catch
			return null
		now = new Date().getTime()
		if not token.validUntil or token.validUntil < now
			return null
		return token.username

	# Return a new encrypted token for the given username
	getNewToken: (username) ->
		validUntil = new Date().getTime() + Config.token_lifetime_ms
		token =
			username: username
			validUntil: validUntil
		encrypt token

	# Add a salt to a password and return the hashed value using sha512
	hashPassword: (password, salt) ->
		hash = Crypto.createHash hashingAlgorithm
		hash.update password + salt, 'utf8'
		hash.digest 'hex'

	#------------------
	# Private Functions
	#------------------
	encrypt = (token) ->
		str = JSON.stringify token
		cipher = Crypto.createCipher 'aes-256-cbc', 'salkmd20934n'
		crypted = cipher.update str,'utf8','hex'
		crypted += cipher.final 'hex'
		crypted
	decrypt = (str) ->
		decipher = Crypto.createDecipher 'aes-256-cbc', 'salkmd20934n'
		token = decipher.update str,'hex','utf8'
		token += decipher.final 'utf8'
		token = JSON.parse token
		token

module.exports = new Authentication()