class ConfirmController
	constructor: ($scope, $http, $routeParams, $location) ->
		$scope.uploadId = ''
		$scope.confirmed = 'waiting'
		$scope.error = ''

		$http.post("/confirm/" + $routeParams.id,
				transformRequest: angular.identity
				headers: {'Content-Type': undefined}
				timeout: 5000
			)
			.success((result) ->
				if result.success
					$scope.uploadId = result.uploadId
					$scope.confirmed = 'confirmed'
					#alert warning if exists
					if result.msg then alert result.msg
				else
					$scope.confirmed = 'denied'
					$scope.error = result.msg
			)
			.error((error) ->
				$scope.error = 'There was a server error while processing your confirmation request'
				$scope.confirmed = 'denied'
			)

angular.module('app').controller 'confirmController', ['$scope', '$http', '$routeParams', '$location', ConfirmController]