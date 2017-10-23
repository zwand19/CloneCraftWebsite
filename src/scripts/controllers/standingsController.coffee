class StandingsController
	constructor: ($scope, $http, $location) ->
		$scope.competitors = []
		$scope.infoBubbles = [
			name: 'Code Uploads'
			total: 0
			value: null
		,
			name: 'Games Played'
			total: 0
			value: null
		,
			name: 'Code Warriors'
			total: 0
			value: null
		,
			name: 'Gold Mined'
			total: 0
			value: 0
		,
			name: 'Minions Killed'
			total: 0
			value: 0
		,
			name: 'Miners Built'
			total: 0
			value: 0
		,
			name: 'Archers Built'
			total: 0
			value: 0
		,
			name: 'Seers Built'
			total: 0
			value: 0
		,
			name: 'Foxes Built'
			total: 0
			value: 0
		,
			name: 'Tanks Built'
			total: 0
			value: 0
		,
			name: 'Greater Minions Built'
			total: 0
			value: 0
		,
			name: 'Lesser Minions Built'
			total: 0
			value: 0
		]

		$scope.selectedTournament =
			scoreboard: []

		$scope.competitorClicked = (name) ->
			$location.path 'CloneCraft/competitor/' + name

		$scope.getCompetitorDominance = (competitor) ->
			(100 * competitor.wins / (competitor.wins + competitor.losses)).toFixed(0) + '%'

		$scope.getSecondaryWinners = () ->
			competitors = []
			scoreboard = $scope.selectedTournament.scoreboard
			if scoreboard[1]
				competitors.push scoreboard[1]
				competitors[0].place = '2nd'
			if scoreboard[2]
				competitors.push scoreboard[2]
				competitors[1].place = '3rd'
			if scoreboard[3]
				competitors.push scoreboard[3]
				competitors[2].place = '4th'
			if scoreboard[4]
				competitors.push scoreboard[4]
				competitors[3].place = '5th'
			return competitors

		$scope.getFieldCompetitors = () ->
			$scope.selectedTournament.scoreboard.slice 5

		$scope.tournamentSelected = () ->
			$scope.selectedTournament.scoreboard = []
			$http.get('/tournaments/' + $scope.selectedTournament.id,
					transformRequest: angular.identity
					headers: {'Content-Type': undefined}
					timeout: 5000
				)
				.success((result) ->
					if not result.success then return alert result.msg
					for i in [0...$scope.tournaments.length]
						if $scope.tournaments[i].id is result.data.id
							$scope.tournaments[i] = result.data
							$scope.selectedTournament = $scope.tournaments[i]
							$scope.infoBubbles[3].value = result.data.goldMined
							$scope.infoBubbles[4].value = result.data.minionsKilled
							$scope.infoBubbles[5].value = result.data.minersBuilt
							$scope.infoBubbles[6].value = result.data.archersBuilt
							$scope.infoBubbles[7].value = result.data.seersBuilt
							$scope.infoBubbles[8].value = result.data.foxesBuilt
							$scope.infoBubbles[9].value = result.data.tanksBuilt
							$scope.infoBubbles[10].value = result.data.greaterMinionsBuilt
							$scope.infoBubbles[11].value = result.data.lesserMinionsBuilt
				)
				.error((error) ->
					alert 'Server Error.'
				)

		$http.get('/tournaments',
				transformRequest: angular.identity
				headers: {'Content-Type': undefined}
				timeout: 5000
			)
			.success((result) ->
				if not result.success then return alert result.msg
				$scope.tournaments = result.data
				if $scope.tournaments.length
					$scope.selectedTournament = $scope.tournaments[0]
					$scope.tournamentSelected()
			)
			.error((error) ->
				alert 'Server Error'
			)

		$http.get('/tournaments-general',
				transformRequest: angular.identity
				headers: {'Content-Type': undefined}
				timeout: 5000
			)
			.success((result) ->
				if not result.success then return alert result.msg
				$scope.infoBubbles[0].total = result.data.codeUploads
				$scope.infoBubbles[1].total = result.data.gamesPlayed
				$scope.infoBubbles[2].total = result.data.codeWarriors
				$scope.infoBubbles[3].total = result.data.goldMined
				$scope.infoBubbles[4].total = result.data.minionsKilled
				$scope.infoBubbles[5].total = result.data.minersBuilt
				$scope.infoBubbles[6].total = result.data.archersBuilt
				$scope.infoBubbles[7].total = result.data.seersBuilt
				$scope.infoBubbles[8].total = result.data.foxesBuilt
				$scope.infoBubbles[9].total = result.data.tanksBuilt
				$scope.infoBubbles[10].total = result.data.greaterMinionsBuilt
				$scope.infoBubbles[11].total = result.data.lesserMinionsBuilt
			)
			.error((error) ->
				alert 'Server Error.'
			)


angular.module('app').controller 'standingsController', ['$scope', '$http', '$location', StandingsController]