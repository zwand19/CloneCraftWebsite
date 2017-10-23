FileManager = require '../../server/game/fileManager'
Helpers = require '../../server/helpers'
Logger = require '../../server/utilities/logger'
Match = require '../../server/game/match'
Q = require 'q'
TestHelpers = require '../testHelpers'
Zipper = require '../../server/utilities/zipper'

describe 'File Manager', ->
	#----------
	# Test data
	#----------
	game1 =
		zipPath: 'path1'
	game2 =
		zipPath: 'path2'
	game3 =
		zipPath: 'path3'

	match = 
		competitor1:
			name: 'comp1'
		competitor2:
			name: 'comp2'
		folderPath: 'path'
		gameInfos: [{}, {}, {}]
		games: [game1, game2, game3]
		statuses: [{}, {}, {}]

	#-----------------
	# Dependency Mocks
	#-----------------
	beforeEach ->
		spyOn(Logger, 'info').andReturn()
		spyOn(Logger, 'log').andReturn()
		spyOn(Logger, 'error').andReturn()
		spyOn(Helpers, 'writeToClonecraftFile').andCallFake(TestHelpers.promisedData('path'))
		spyOn(Zipper, 'zipAndDeleteFiles').andCallFake(TestHelpers.promiseFunction)

	#-----------
	# Unit Tests
	#-----------
	describe 'writing matches to file', ->
		it 'should return the match', (done) ->
			FileManager.writeRoundRobinMatchToFile(match)
			.then (result) ->
				expect(result).toBe(match)
			.catch (error) ->
				TestHelpers.fail()
			.done () ->
				done()
				
		it 'should throw zipper errors', (done) ->
			Zipper.zipAndDeleteFiles.andCallFake(TestHelpers.promiseError)
			failed = false
			FileManager.writeRoundRobinMatchToFile(match)
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()
				
		it 'should throw writing to file errors', (done) ->
			Helpers.writeToClonecraftFile.andCallFake(TestHelpers.promiseError)
			failed = false
			FileManager.writeRoundRobinMatchToFile(match)
			.catch () ->
				failed = true
			.done () ->
				expect(failed).toBeTruthy()
				done()