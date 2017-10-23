Q = require 'q'

Helpers =
	callback: () ->
		args = arguments
		process.nextTick () ->
			args[args.length - 1]()

	callbackError: () ->
		args = arguments
		process.nextTick () ->
			args[args.length - 1](new Error())

	callbackStringArray: () ->
		args = arguments
		process.nextTick () ->
			args[args.length - 1](null, ['a', 'b', 'c'])

	fail: (err) ->
		if err then console.log err
		expect(true).toBeFalsy()

	pass: () ->
		expect(true).toBeTruthy()

	promisedData: (data) ->
		() ->
			deferred = Q.defer()
			process.nextTick () -> deferred.resolve(data)
			deferred.promise

	promiseError: () ->
		deferred = Q.defer()
		process.nextTick () -> deferred.reject new Error 'test error'
		deferred.promise

	promiseFunction: () ->
		deferred = Q.defer()
		process.nextTick () -> deferred.resolve()
		deferred.promise
		
module.exports = Helpers