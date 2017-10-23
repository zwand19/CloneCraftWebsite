BotSetup = require '../../../server/utilities/botSetup'
Helpers = require '../../../server/helpers'
Logger = require '../../../server/utilities/logger'
Q = require 'q'
ShellCommandRunner = require '../../../server/utilities/shellCommandRunner'
TestHelpers = require '../../testHelpers'

describe 'BotSetup utility', ->
	#----------
	# Test Data
	#----------
	competitor =
		code_folder: 'folder/subfolder'
		name: 'Competitor One'
		
	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Helpers, 'copyDirectoryRecursively').andCallFake(TestHelpers.promiseFunction)
		spyOn(Helpers, 'makeDirectoryRecursively').andCallFake(TestHelpers.promiseFunction)
		spyOn(ShellCommandRunner, 'execute').andCallFake(TestHelpers.promiseFunction)
		spyOn(ShellCommandRunner, 'spawn').andReturn()
		
	#-----------
	# Unit Tests
	#-----------
	describe 'initializeCompetitor', ->
		it 'can initialize a CSharp competitor', (done) ->
			BotSetup.initializeCompetitor(competitor, 'C-Sharp')
				.catch (err) ->
					TestHelpers.fail()
				.then () ->
					expect(Helpers.copyDirectoryRecursively).toHaveBeenCalledWith('./StarterBots/c-sharp', 'CompetitorCode\\Competitor One')
					expect(Helpers.makeDirectoryRecursively).toHaveBeenCalledWith('CompetitorCode\\Competitor One')
					expect(ShellCommandRunner.execute).toHaveBeenCalled()
				.done () ->
					done()
				
		it 'can initialize a Node competitor', (done) ->
			BotSetup.initializeCompetitor(competitor, 'Node')
				.catch (err) ->
					console.log err
					TestHelpers.fail()
				.then () ->
					expect(Helpers.copyDirectoryRecursively).toHaveBeenCalledWith('./StarterBots/node', 'CompetitorCode\\Competitor One')
					expect(Helpers.makeDirectoryRecursively).toHaveBeenCalledWith('CompetitorCode\\Competitor One')
					expect(ShellCommandRunner.spawn).toHaveBeenCalled()
				.done () ->
					done()

		it 'throws error on null competitor', (done) ->
			try
				BotSetup.initializeCompetitor(null, 'Node')
				TestHelpers.fail()
			catch e
				TestHelpers.pass()
			finally
				done()

		it 'throws error if competitor name not defined', (done) ->
			try
				BotSetup.initializeCompetitor({ code_folder: './' }, 'Node')
				TestHelpers.fail()
			catch e
				TestHelpers.pass()
			finally
				done()

		it 'throws error if competitor code folder not defined', (done) ->
			try
				BotSetup.initializeCompetitor({ name: 'Kyle' }, 'Node')
				TestHelpers.fail()
			catch e
				TestHelpers.pass()
			finally
				done()

		it 'throws error on invalid language', (done) ->
			try
				BotSetup.initializeCompetitor(competitor, 'Fortran')
				TestHelpers.fail()
			catch e
				TestHelpers.pass()
			finally
				done()