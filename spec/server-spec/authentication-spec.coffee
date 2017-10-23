Authentication = require '../../server/authentication'
Logger = require '../../server/utilities/logger'
Mongo = require '../../server/utilities/mongoClient'
Q = require 'q'
TestHelpers = require '../testHelpers'

describe 'Authentication', ->
	#----------
	# Test data
	#----------
	competitor = 
		name: 'username'
		password: ''
		salt: ''

	password = 'password'
	salt = 'mylongsalt'

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		storage = {}
		localStorage =
			setItem: (key, item) ->
				storage[key] = item
			getItem: (key) ->
				storage[key]
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Mongo, 'getCompetitor').andCallFake(TestHelpers.promisedData(competitor))
		competitor.password = Authentication.hashPassword password, salt
		competitor.salt = salt

	#-----------
	# Unit Tests
	#-----------
	describe 'authenticateLogin', ->
		it 'should return a token', (done) ->
			Authentication.authenticateLogin('username', 'password')
			.catch ->
				TestHelpers.fail()
			.then (result) ->
				expect(result).not.toBeNull()
				expect(result.token).not.toBeNull()
			.finally ->
				done()

		it 'should return username when using email as credential', (done) ->
			Authentication.authenticateLogin('email@geneca.com', 'password')
			.catch ->
				TestHelpers.fail()
			.then (result) ->
				expect(result.username).toBe('username')
			.finally ->
				done()

		it 'should throw db errors', (done) ->
			Mongo.getCompetitor.andCallFake TestHelpers.promiseError
			Authentication.authenticateLogin('username', 'password')
			.then ->
				TestHelpers.fail()
			.catch ->
				TestHelpers.pass()
			.finally ->
				done()

		it 'should throw error when username not in db', (done) ->
			Mongo.getCompetitor.andCallFake TestHelpers.promisedData null
			Authentication.authenticateLogin('username', 'password')
			.then ->
				TestHelpers.fail()
			.catch ->
				TestHelpers.pass()
			.finally ->
				done()

		it 'should throw error on wrong password', (done) ->
			Mongo.getCompetitor.andCallFake TestHelpers.promisedData null
			Authentication.authenticateLogin('username', 'wrongPassword')
			.then ->
				TestHelpers.fail()
			.catch ->
				TestHelpers.pass()
			.finally ->
				done()

	describe 'authenticateToken', ->
		it 'should be able to authenticate a token created by login', (done) ->
			username = ''
			Authentication.authenticateLogin('username', 'password')
			.then (result) ->
				username = Authentication.authenticateToken(result.token)
			.finally ->
				expect(username).toBe('username')
				done()

