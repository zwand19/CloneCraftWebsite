CodeReceiver = require '../../../server/codeupload/codereceiver'
FS = require 'fs-extra'
Helpers = require '../../../server/helpers'
HttpClient = require '../../../server/utilities/httpClient'
Logger = require '../../../server/utilities/logger'
Mongo = require '../../../server/utilities/mongoClient'
Q = require 'q'
ServerStatus = require '../../../server/serverStatus'
TestHelpers = require '../../testHelpers'
Zipper = require '../../../server/utilities/zipper'

describe 'Standings', ->
	#----------
	# Test data
	#----------
	competitor = 
		name: 'johnnyd'
		email: 'johnnyd@geneca.com'
		language: 'C-Sharp'
		uploads: 14
		last_uploaded: '05/17/2014 10:29:11'
		confirmed: true
		code_folder: 'code/folder/johnnyd'

	nodeCompetitor =  
		name: 'johnnyd'
		email: 'johnnyd@geneca.com'
		language: 'Node'
		uploads: 14
		last_uploaded: '05/17/2014 10:29:11'
		confirmed: true
		code_folder: 'code/folder/johnnyd'

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(FS, 'remove').andCallFake(TestHelpers.callback)
		spyOn(Helpers, 'copyDirectoryRecursively').andCallFake(TestHelpers.promiseFunction)
		spyOn(Helpers, 'makeDirectoryRecursively').andCallFake(TestHelpers.promiseFunction)
		spyOn(HttpClient, 'get').andCallFake(TestHelpers.promiseFunction)
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Mongo, 'getCompetitor').andCallFake(TestHelpers.promisedData(competitor))
		spyOn(Mongo, 'findAndModifyCompetitor').andCallFake(TestHelpers.promisedData(competitor))
		spyOn(Zipper, 'unzipAndDelete').andCallFake(TestHelpers.promiseFunction)

	#-----------
	# Unit Tests
	#-----------
	describe 'handleUpload', ->
		it 'should return success', (done) ->
			failed = false
			CodeReceiver.handleUpload('path/to/zip', '1a2b3c')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeFalsy()
				done()

		it 'should throw error if competitor not found', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promisedData(null))
			failed = false
			CodeReceiver.handleUpload('path/to/zip', '1a2b3c')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

		it 'should throw error if competitor not confirmed', (done) ->
			Mongo.getCompetitor.andCallFake(TestHelpers.promisedData({confirmed: false}))
			failed = false
			CodeReceiver.handleUpload('path/to/zip', '1a2b3c')
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()

		it 'should throw error if tournament is running', (done) ->
			ServerStatus.runningTournament = true
			failed = false
			CodeReceiver.handleUpload('path/to/zip', '1a2b3c')
			.catch () ->
				failed = true
			.done () ->
				ServerStatus.runningTournament = false
				expect(failed).toBeTruthy()
				done()

		describe 'c-sharp competitors', ->
			it 'should call unzip', (done) ->
				CodeReceiver.handleUpload('path/to/zip', '1a2b3c')
				.then () ->
					expect(Zipper.unzipAndDelete).toHaveBeenCalled()
				.catch () ->
					TestHelpers.fail()
				.done () ->
					done()

		describe 'node competitors', ->
			it 'should call helpers', (done) ->
				Mongo.findAndModifyCompetitor.andCallFake(TestHelpers.promisedData(nodeCompetitor))
				CodeReceiver.handleUpload('path/to/zip', '1a2b3c')
				.then () ->
					expect(Zipper.unzipAndDelete).toHaveBeenCalled()
					expect(FS.remove).toHaveBeenCalled()
				.catch (err) ->
					TestHelpers.fail()
				.done () ->
					done()