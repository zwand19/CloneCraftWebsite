Fs = require 'fs-extra'
Logger = require '../../../server/utilities/logger'
Mongo = require '../../../server/utilities/mongoClient'
NodeStartup = require '../../../server/utilities/nodeStartup'
ShellCommandRunner = require '../../../server/utilities/shellCommandRunner'
TestHelpers = require '../../testHelpers'

describe 'NodeStartup utility', ->
	#----------
	# Test data
	#----------
	competitors = [
			name: 'competitor one'
			port: 25
			code_folder: './Comp1'
		,
			name: 'competitor two'
			port: 26
			code_folder: './Comp2'
		,
			name: 'competitor three'
			port: 27
			code_folder: './Comp3'
		]

	#-------------
	# Test Helpers
	#-------------
	checkScriptFile = (command, args, competitorName) ->
		if Fs.existsSync command
			TestHelpers.pass()
		else TestHelpers.fail()
		
	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Mongo, 'getCompetitors').andCallFake(TestHelpers.promisedData(competitors))
		spyOn(ShellCommandRunner, 'execute').andCallFake(checkScriptFile)
		spyOn(ShellCommandRunner, 'spawn').andCallFake(checkScriptFile)
		
	#-----------
	# Unit Tests
	#-----------
	describe 'startNodeServers', ->
		it 'can execute startNodeServers', (done) ->
			failed = false
			NodeStartup.startNodeServers()
				.catch (err) ->
					failed = true
				.done ->
					expect(failed).toBeFalsy()
					done()

		it 'spawns node servers', (done) ->
			callCount = 0
			ShellCommandRunner.spawn.andCallFake () ->
				callCount++
				TestHelpers.promiseFunction()
			NodeStartup.startNodeServers()
				.catch (err) ->
					TestHelpers.fail()
				.then ->
					expect(callCount).toBe(competitors.length)
				.done ->
					done()
				
		it 'throws db errors', (done) ->
			Mongo.getCompetitors.andCallFake(TestHelpers.promiseError)
			failed = false
			NodeStartup.startNodeServers()
				.catch (err) ->
					failed = true
				.done ->
					expect(failed).toBeTruthy()
					done()
