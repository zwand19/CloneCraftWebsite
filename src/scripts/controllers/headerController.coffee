class HeaderController
	constructor: ($scope, $location, $http, $rootScope, authService) ->
		#----------
		# Variables
		#----------
		$scope.backTo = null
		$scope.currentPage = 'home'
		$scope.expandedNavbar = false
		$scope.formType = 'login'
		$scope.header = 'big'
		$scope.loggedIn = false
		$scope.loginCredential = ''
		$scope.loginPassword = ''
		$scope.navbarColor = null
		$scope.registerUsername = ''
		$scope.registerEmail = ''
		$scope.registerPassword = ''
		$scope.registerPasswordConfirmation = ''
		$scope.showLoginPopup = false
		$scope.waitingOnServer = false
		$scope.username = ''
		# Set our default header content type
		$http.defaults.headers.post["Content-Type"] = "application/json"

		#---------------
		# Event Handlers
		#---------------

		window.onresize = ->
			$scope.expandedNavbar = false
			$scope.$apply()

		setHeader = (path) ->
			setHeaderInfo = (header, currentPage, navbarColor, backTo) ->
				$scope.header = header
				$scope.currentPage = currentPage
				$scope.navbarColor = navbarColor
				$scope.backTo = backTo
			switch path
				when '/'
					setHeaderInfo 'big', 'home', null, null
				when '/clonecraft'
					setHeaderInfo 'normal', 'cloneCraft', 'red', 'codeWars'
				when '/clonecraft/docs'
					setHeaderInfo 'normal', 'docs', 'red', 'cloneCraft'
				when '/clonecraft/standings'
					setHeaderInfo 'normal', 'standings', 'red', 'cloneCraft'
				when '/clonecraft/upload'
					setHeaderInfo 'normal', 'upload', 'red', 'cloneCraft'
				when '/clonecraft/game'
					setHeaderInfo 'normal', 'game', 'red', 'cloneCraft'
				when '/about'
					setHeaderInfo 'big', 'home', null, null
				when '/warriors'
					setHeaderInfo 'big', 'home', null, null
				else
					if path.indexOf('/clonecraft/competitor') is 0
						setHeaderInfo 'normal', 'competitor', 'red', 'cloneCraft'
					if path.indexOf('/confirm') is 0
						setHeaderInfo 'normal', 'confirm', 'red', 'codeWars'

		angular.element(document).ready ->
			setHeader $location.path().toLowerCase()

		# Whenever we go to a page set information to display the correct header
		$rootScope.$on '$routeChangeSuccess', (e, current, pre) ->
			setHeader current.$$route.originalPath.toLowerCase()

		#--------------
		# Scope Methods
		#--------------
		$scope.expandedStyle = ->
			if $scope.expandedNavbar then 'block' else 'none'

		$scope.hideLoginPopup = ->
			$scope.showLoginPopup = false

		$scope.login = ->
			return if $scope.waitingOnServer
			$scope.waitingOnServer = true
			authService.login $scope.loginCredential, $scope.loginPassword, loginCallback

		$scope.loginIfEnter = (e) ->
			if e.keyCode is 13 then $scope.login()

		$scope.logout = ->
			authService.logout()
			$scope.loggedIn = false
			$scope.username = ''
			headerButtonClicked()

		$scope.register = ->
			return if $scope.waitingOnServer
			if $scope.registerPassword isnt $scope.registerPasswordConfirmation
				return alert 'Your passwords do not match'
			$scope.waitingOnServer = true
			authService.register $scope.registerEmail, $scope.registerUsername, $scope.registerPassword, $scope.api_url, registerCallback

		$scope.registerIfEnter = (e) ->
			if e.keyCode is 13 then $scope.register()

		$scope.showLogin = ->
			$scope.showLoginPopup = true
			$scope.formType = 'login'
			headerButtonClicked()
			setTimeout ->
				document.getElementById('loginCredential').focus()
			, .5

		$scope.showRegister = ->
			$scope.showLoginPopup = true
			$scope.formType = 'register'
			setTimeout ->
				document.getElementById('registerEmail').focus()
			, .5

		#----------------------
		# Header Button Methods
		#----------------------

		$scope.docsClicked = ->
			$location.path 'CloneCraft/docs'
			headerButtonClicked()

		$scope.overviewClicked = ->
			$location.path 'CloneCraft'
			headerButtonClicked()

		$scope.playClicked = ->
			$location.path 'CloneCraft/game'
			headerButtonClicked()

		$scope.profileClicked = ->
			$location.path "CloneCraft/competitor/#{authService.getUsername()}"
			headerButtonClicked()

		$scope.standingsClicked = ->
			$location.path 'CloneCraft/standings'
			headerButtonClicked()

		$scope.uploadClicked = ->
			$location.path 'CloneCraft/upload'
			headerButtonClicked()

		#----------------
		# Private Methods
		#----------------
		headerButtonClicked = ->
			$scope.expandedNavbar = false

		loginCallback = (err) ->
			$scope.waitingOnServer = false
			if err
				alert err
			else
				$scope.loggedIn = true
				$scope.showLoginPopup = false
				$scope.username = authService.getUsername()

		registerCallback = (err) ->
			$scope.waitingOnServer = false
			if err
				alert err
			else
				$scope.loggedIn = true
				$scope.showLoginPopup = false
				$scope.username = authService.getUsername()
				alert 'You are now registered! Confirmation email sent'

		if authService.isLoggedIn()
			loginCallback()

angular.module('app').controller 'headerController', ['$scope', '$location', '$http', '$rootScope', 'authService', HeaderController]