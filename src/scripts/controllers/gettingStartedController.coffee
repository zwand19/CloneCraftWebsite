class GettingStartedController
	constructor: ($scope, $location, authService) ->
		$scope.loggedIn = authService.isLoggedIn()

		$scope.tryGameClicked = ->
			$location.path '/CloneCraft/game'

		authService.onLoggedIn ->
			$scope.loggedIn = true

		authService.onLoggedOut ->
			$scope.loggedIn = false

angular.module('app').controller 'gettingStartedController', ['$scope', '$location', 'authService', GettingStartedController]