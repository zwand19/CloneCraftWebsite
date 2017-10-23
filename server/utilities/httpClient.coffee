Logger = require './logger'
Request = require 'request'
Q = require 'q'

class HttpClient
	get: (options) ->
		deferred = Q.defer()
		Request.get options, (err, response, responseData) ->
			if err
				deferred.reject err
			else if response.statusCode isnt 200
				deferred.reject new Error "Http GET Error Code: #{response.statusCode}"
			else deferred.resolve responseData
		deferred.promise

	# Wraps Request.post in a promise
	# Throws error on non-200 response
	post: (options) ->
		deferred = Q.defer()
		Request.post options, (err, response, responseData) ->
			if err
				deferred.reject err
			else if response.statusCode isnt 200
				deferred.reject new Error "Http POST Error Code: #{response.statusCode}"
			else deferred.resolve responseData
		deferred.promise


module.exports = new HttpClient()