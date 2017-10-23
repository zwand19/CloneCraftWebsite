Constants = require '../../server/settings/constants'
Resource = require '../../server/entities/resource'

describe 'Resource', () ->
	resource = {}
	
	beforeEach () -> 
		resource = new Resource(1, 1, 1)

	describe 'Constructor', () ->
		it 'should default to being active', () ->
			expect(resource.isActive).toBeTruthy()

	describe 'mined', () ->
		it 'should set the resource to be not active', () ->
			resource.mined()
			expect(resource.isActive()).toBeFalsy()

	describe 'turnElapsed', () ->
		it 'should keep the resource active if it already was', () ->
			resource.onBoard = true
			resource.turnElapsed()
			expect(resource.isActive()).toBeTruthy()