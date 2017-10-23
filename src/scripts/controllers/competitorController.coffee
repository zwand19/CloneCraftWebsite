class CompetitorController
	constructor: ($scope, $http, $routeParams, authService) ->
		$scope.edittedBlurb = ''
		$scope.edittingBlurb = false

		$scope.editBlurb = ->
			$scope.edittingBlurb = true
			$scope.edittedBlurb = $scope.competitor.blurb
			# give time for ng-show to apply then focus the input
			# TODO: make directive to do this the 'angular way'
			setTimeout ->
				document.getElementById("blurb-input").focus()
			, 20

		$scope.getResultClass = (result) ->
			if result is 'win' then return 'win-result'
			if result is 'loss' then return 'loss-result'
			if result is 'draw' then return 'draw-result'

		$scope.showEditBlurb = ->
			$scope.competitor.name is authService.getUsername() and !$scope.edittingBlurb

		$scope.showStats = (tournament) ->
			$scope.showStatsPopup = true
			$scope.stats = tournament

		$scope.tourneyButtonClicked = (tournament) ->
			tournament.opened = !tournament.opened
			if not tournament.loaded
				$http.get("/competitors/#{$scope.competitor.name}/#{tournament.id}",
						transformRequest: angular.identity
						headers: {'Content-Type': undefined}
						timeout: 5000
					)
					.success((matches) ->
						tournament.loaded = true
						tournament.matches = matches.data
						for m in tournament.matches
							m.opened = false
					)
					.error((error) ->
						alert 'Server Error.'
						tournament.opened = false
					)

		$scope.updateProfile = ->
			try
				headers = authService.getAuthHeader()
			catch
				return alert "You must be logged in to upload code"
			data =
				blurb: $scope.edittedBlurb
			$http.post('/updateProfile', JSON.stringify(data),
					transformRequest: angular.identity
					headers: headers
					timeout: 5000
				)
				.success((result) ->
					if result.success
						$scope.edittingBlurb = false
						$scope.competitor.blurb = $scope.edittedBlurb
					else
						alert result.msg
				)
				.error((error, code) ->
					if code is 401
						alert 'Invalid Session Token. Please try logging out and back in'
					else alert 'Server Error.'
					$scope.edittingBlurb = false
				)

		initialize = () ->
			$scope.competitor =
				name: $routeParams.name
				gravatar: ''
				tournaments: []
		
			$scope.showStatsPopup = false

			$http.get("/competitors/#{$scope.competitor.name}",
					transformRequest: angular.identity
					headers: {'Content-Type': undefined}
					timeout: 5000
				)
				.success((result) ->
					if not result.success then return alert result.msg
					$scope.competitor = result.data
					for t in $scope.competitor.tournaments
						t.opened = false
						t.loaded = false
				)
				.error((error) ->
					alert 'Server Error.'
				)

		initialize()

angular.module('app').controller 'competitorController', ['$scope', '$http', '$routeParams', 'authService', CompetitorController]