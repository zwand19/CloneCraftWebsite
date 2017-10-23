class AuthService
	constructor: ($http) ->
		@http = $http
		@logInCallbacks = []
		@logOutCallbacks = []

	#---------------
	# Public Methods
	#---------------
	getAuthHeader: ->
		token = localStorage.getItem 'token'
		if not token then throw new Error()
		return {
			authToken: token
		}

	getAuthToken: ->
		localStorage.getItem 'token'

	getUsername: ->
		localStorage.getItem 'username'

	isLoggedIn: ->
		localStorage.getItem('token') isnt null and localStorage.getItem('token') isnt "null"

	login: (credential, password, callback) ->
		ensureSupportsHtml5Storage callback
		_this = @
		@http.post("/login",
				transformRequest: angular.identity
				headers: {'Content-Type': undefined}
				timeout: 5000
				data:
					credential: credential
					password: password
			)
			.success((result) ->
				if result.success
					setToken result.token
					setUsername result.username
					for logInCallback in _this.logInCallbacks
						logInCallback()
					callback null
				else
					callback 'Could not find user with given credential and password'
			)
			.error((error) ->
				callback 'Server Error. Please try again'
			)

	logout: ->
		localStorage.setItem 'token', null
		localStorage.setItem 'username', null
		for callback in @logOutCallbacks
			callback()

	onLoggedIn: (callback) ->
		@logInCallbacks.push callback

	onLoggedOut: (callback) ->
		@logOutCallbacks.push callback

	register: (email, username, password, language, callback) ->
		ensureSupportsHtml5Storage callback
		@http.post("/register",
				transformRequest: angular.identity
				headers: {'Content-Type': undefined}
				timeout: 5000
				data:
					email: email
					password: password
					username: username
					language: language
			)
			.success((result) ->
				if result.success
					setToken result.token
					setUsername username
					callback null
				else
					callback result.msg
			)
			.error((error) ->
				callback 'Server Error. Please try again'
			)

	#----------------
	# Private Methods
	#----------------
	ensureSupportsHtml5Storage = (callback) ->
		supported = false
		try
			supported = 'localStorage' of window and window['localStorage'] isnt null
		finally
			if not supported
				callback 'This browser is not supported (does not support local storage). Please try a different browser'
				throw new Error()

	setToken = (token) ->
		localStorage.setItem 'token', token

	setUsername = (username) ->
		localStorage.setItem 'username', username
			
angular.module('app').service 'authService', ['$http', AuthService]