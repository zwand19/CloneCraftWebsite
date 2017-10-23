BotSetup = require '../../server/utilities/botSetup'
Helpers = require '../../server/helpers'
Logger = require '../../server/utilities/logger'
MailService = require '../../server/utilities/emailService'
Mongo = require '../../server/utilities/mongoClient'
Q = require 'q'
Register = require '../../server/competitors/register'
TestHelpers = require '../testHelpers'

describe 'Register', ->
	#----------
	# Test data
	#----------
	competitor = 
		name: 'johnnyd'
		email: 'johnnyd@geneca.com'
		language: 'C-Sharp'
		registered_on: '05/12/2014 10:14:00'
		uploads: 14
		gold_mined: 10242
		game_wins: 162
		game_losses: 52
		match_wins: 22
		match_losses: 8
		match_draws: 1
		minions_killed: 241
		miners_built: 160
		archers_built: 242
		seers_built: 191
		foxes_built: 214
		tanks_built: 0
		gravatar: 'www.gravatar.com/comp'
		last_uploaded: '05/17/2014 10:29:11'
		greater_minions_built: 160 + 242 + 191 + 214 + 5 - 51
		lesser_minions_built: 51
		grunts_built: 5

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Mongo, 'addCompetitor').andCallFake(TestHelpers.promisedData(competitor))
		spyOn(Mongo, 'getCompetitor').andCallFake(TestHelpers.promisedData())
		spyOn(Mongo, 'getNewCompetitorPort').andCallFake(TestHelpers.promisedData(3001))
		spyOn(BotSetup, 'initializeCompetitor').andCallFake(TestHelpers.promisedData())
		spyOn(MailService, 'sendRegistrationEmail').andCallFake(TestHelpers.promisedData())

	#-----------
	# Unit Tests
	#-----------
	describe 'register', ->
		it 'should return success on valid input', (done) ->
			Register.register('email@geneca.com', '', 'uname', 'password', 'Node')
			.then () ->
				TestHelpers.pass()
			.catch (err) ->
				TestHelpers.fail()
			.done () ->
				done()

		it 'should return success on valid input for non-genecians', (done) ->
			Register.register('email@notgeneca.com', 'first.last@geneca.com', 'uname', 'password', 'Node')
			.then () ->
				TestHelpers.pass()
			.catch (err) ->
				TestHelpers.fail()
			.done () ->
				done()

		describe 'error handling', ->
			it 'should throw errors db errors on getCompetitor', (done) ->
				Mongo.getCompetitor.andCallFake(TestHelpers.promiseError())
				Register.register('email@geneca.com', '', 'uname', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should throw errors when registration not unique', (done) ->
				Mongo.getCompetitor.andCallFake(TestHelpers.promisedData(competitor))
				Register.register('email@geneca.com', '', 'uname', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should throw errors on getNewCompetitorPort call', (done) ->
				Mongo.getNewCompetitorPort.andCallFake(TestHelpers.promiseError())
				Register.register('email@geneca.com', '', 'uname', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should throw bot setup errors', (done) ->
				BotSetup.initializeCompetitor.andCallFake(TestHelpers.promiseError())
				Register.register('email@geneca.com', 'uname', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should throw mail service errors', (done) ->
				MailService.sendRegistrationEmail.andCallFake(TestHelpers.promiseError())
				Register.register('email@geneca.com', '', 'uname', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

		describe 'validation', ->
			it 'should only accept geneca emails if no sponsor', (done) ->
				Register.register('email@notgeneca.com', '', 'uname', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should not accept usernames under 3 characters', (done) ->
				Register.register('email@geneca.com', '', 'un', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should not accept usernames over 20 characters', (done) ->
				Register.register('email@geneca.com', '', '123456789012345678901', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should not accept the username king', (done) ->
				Register.register('email@geneca.com', '', 'king', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should not accept usernames with spaces', (done) ->
				Register.register('email@geneca.com', '', 'my name', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should not accept usernames with a special character', (done) ->
				Register.register('email@geneca.com', '', 'name?', 'password', 'Node')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()

			it 'should not accept an invalid language', (done) ->
				Register.register('email@geneca.com', '', 'name', 'password', 'Fortran')
				.then () ->
					TestHelpers.fail()
				.catch () ->
					TestHelpers.pass()
				.done () ->
					done()